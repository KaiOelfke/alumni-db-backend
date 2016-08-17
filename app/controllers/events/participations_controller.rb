class Events::ParticipationsController < ApplicationController
  before_action :authenticate_user!

  # TODO implement paging
  def index
    @current_user = current_user
    unless current_user.is_super_user
      raise Forbidden
    end
    unless params[:event_id]
      raise BadRequest, errors: ['event_id is required']
    end
    @event = Events::Event.find_by_id( params[:event_id])
    if @event
      success_response( @event.participations)
    else
      raise NotFound
    end
  end

  def show
    @current_user = current_user
    unless params[:id]
      raise BadRequest errors: ['participation_id is required']
    end
    unless params[:event_id]
      raise BadRequest errors: ['event_id is required']
    end
    @participation = Events::Participation.find_by_id( params[:id])
    if @participation
      if current_user.is_super_user or @participation.user.id.eql? current_user.id
        success_response( @participation)
      else
        raise Forbidden
      end
    else
      raise NotFound
    end
  end

  # def update
  #   @current_user = current_user
  #   @participation = Events::Participation.find_by_id( params[:id])
  #   if @participation
  #     if (@participation.user_id.eql? @current_user.id and @participation.submitted?) or
  #        @current_user.is_super_user
  #       if @participation.update update_participation_form
  #         success_response( @participation)
  #       else
  #         raise InternalServerError, record: @participation
  #       end
  #     else
  #       raise Forbidden
  #     end
  #   else 
  #     raise NotFound
  #   end
  # end

  def create
    @current_user = current_user
    unless params[:event_id]
      raise BadRequest, errors: ['event_id is required']
    end
    @event = Events::Event.find_by_id( params[:event_id])
    unless @event
      raise NotFound
    end
    unless params[:participation]
      raise BadRequest, errors: ['participation is required']
    end

    if @event.without_application_payment? 
      newParticipation = create_participation_params
      newParticipation[:user_id] = newParticipation[:user_id] || @current_user.id
      @participation = @event.participations.new(create_participation_params)
      if @participation.save
        success_response(@participation)
        return
      else
        raise InternalServerError, record: @participation
      end
    end

    #requires code for proving successful application
    if @event.with_application?
      validate_code
      newParticipation = create_participation_params
      newParticipation["fee_code_id"] = @code.id
      newParticipation[:user_id] = newParticipation[:user_id] || @current_user.id
      @participation = @event.participations.new(create_participation_params)
      if @participation.save
        success_response(@participation)
        return
      else
        raise InternalServerError, record: @participation
      end
    end

    if @event.with_payment?
      validate_fee
      if !@fee.public_fee
        validate_code
        unless @code.fee_id == @fee.id
          raise BadRequest, errors: ['code and fee do not match']
        end
      end
      pay_and_save
      return
    end

    if @event.with_payment_application?
      validate_fee
      validate_code
      if !@fee.public_fee
        unless @code.fee_id == @fee.id
          raise BadRequest, errors: ['code and fee do not match']
        end
      end
      pay_and_save
    end
  end


  # def destroy
  #   @current_user = current_user
  #   @participation = Events::Participation.find_by_id( params[:id])
  #   if @participation
  #     if (@participation.user_id.eql? @current_user.id and @participation.submitted?) or
  #       @current_user.is_super_user
  #       @participation.delete_flag = true
  #       if @participation.save
  #         success_response( @participation)
  #       else
  #         raise InternalServerError, record: @participation
  #       end
  #     else
  #       raise Forbidden
  #     end
  #   else 
  #     raise NotFound
  #   end
  # end

  private 

  # create braintree customer and check/update the payment method (credit card)
  # save braintree customer id if user dosent have any  
  # need
  # @nonce_from_the_client
  # @current_user
  # will set
  # @customer instance
  def create_customer
    # create braintree customer if no customer_id for the user exists
    unless @current_user.customer_id?
      customerResponse = Braintree::Customer.create(
        :first_name => @current_user.first_name,
        :last_name => @current_user.last_name,
        :email => @current_user.email,
        :credit_card => {
          :payment_method_nonce => @nonce_from_the_client,
          :options => {
            :verify_card => true
          }
        }
      )
    else
      customerResponse = Braintree::Customer.update(
        @current_user.customer_id,
        :credit_card => {
          :payment_method_nonce => @nonce_from_the_client,
          :options => {
            :verify_card => true
          }
        }
      )
    end     
    if customerResponse.success?
      @customer = customerResponse.customer
      unless @current_user.customer_id?
        @current_user.customer_id = @customer.id
        unless @current_user.save
          raise InternalServerError, record: @current_user
        end
      end
    elsif customerResponse.credit_card_verification
      @verification = customerResponse.credit_card_verification
      if @verification.status.eql?("gateway_rejected")
        raise InternalServerError, errors: [{ status: @verification.status,
                                             message: @verification.gateway_rejection_reason}]
      elsif @verification.status.eql?("processor_declined")
        raise InternalServerError, errors: [{ status: @verification.status,
                                             code: @verification.processor_response_code,
                                             message:@verification.processor_response_text}]
      else 
        raise InternalServerError, errors: [{ status: "unknown_error",
                                             message: "unknown server error"}]
      end
    else
      raise InternalServerError, record: customerResponse
    end
  end

  # need
  # @currend_user
  # @customer
  # @fee
  def pay_fees
    transactionRequest = {
      :amount => @fee.price,
      :customer_id => @current_user.customer_id,
      :options => {
        :store_in_vault_on_success => true,
        :submit_for_settlement => true
      },
      :payment_method_token => @customer.payment_methods[0].token
    }
    transactionResponse = Braintree::Transaction.sale(transactionRequest)
    transaction = transactionResponse.transaction
    if not transactionResponse.success?
      if transactionResponse.errors.any?
        raise InternalServerError record: transaction   
      else 
      transcation_status = transaction.status or "processor_declined"
      transcation_message = transaction.processor_response_text or
                             transaction.processor_settlement_response_text or "unknown_error"
      transaction_code = transaction.processor_response_code or
                          transaction.processor_settlement_response_code or "unknown server error"
      raise InternalServerError, errors:  [{status: transcation_status,
                                           code:   transaction_code,
                                           message:transcation_message}]
      end
    end

    return transaction.id
  end


  def create_participation_params
    params.require(:participation).permit(:user_id, :fee_id, :arrival, :departure,
    :diet, :allergies, :extra_nights, :other, :fee_code_id)
  end

  # def update_participation_form
  #   if @current_user.is_super_user
  #     params.require(:participation).permit(:status, :arrival, :departure,
  #     :diet, :allergies, :extra_nights, :other)    
  #   else
  #     params.require(:participation).permit(:arrival, :departure,
  #     :diet, :allergies, :extra_nights, :other)    

  #   end
  # end

  def validate_code
    unless params["code"]
      raise BadRequest, errors: ['code is required for this event']
    end
    @code = Events::FeeCode.where( code: params[:code]).take
    unless @code
      raise NotFound, errors: ['code not found']
    end
    if @code.event.id != @event.id
      raise BadRequest, errors: ['code not for this event']
    end
    if @code.user and @code.user.id != current_user.id
      raise NotFound, errors: ['code is not valid']
    end
    if @code.used_flag
      raise NotFound, errors: ["code is already used"]
    end
  end

  def validate_fee
    unless params[:participation][:fee_id]
      raise BadRequest, errors: ['fee_id is missing']
    end
    @fee = Events::Fee.find_by_id(params[:participation][:fee_id])
    unless @fee
      raise NotFound, errors: ['fee not found']
    end
    unless @fee.event_id == @event.id
      raise BadRequest, errors: ['fee does not match event id']
    end
  end

  def pay_and_save
    @nonce_from_the_client = params[:participation][:payment_method_nonce]
    unless @nonce_from_the_client
      raise BadRequest, errors: ['payment_method_nonce is required']
    end
    # Validate model before payment
    testParams = create_participation_params
    testParams[:user_id] = testParams[:user_id] || @current_user.id
    testParams[:event_id] = testParams[:event_id] || @event.id
    testParams[:fee_id] = testParams[:fee_id] || @fee.id
    testParams[:fee_code_id] = testParams[:fee_code_id] || @code.id unless @fee.public_fee
    @testParticipation = Events::Participation.new(testParams)
    @testParticipation.validating_before_payment = true
    unless @testParticipation.valid?
      raise BadRequest, record: @testParticipation
    end
    create_customer
    @participationsParams = create_participation_params
    @participationsParams[:braintree_transaction_id] = pay_fees
    @participationsParams[:user_id] = @participationsParams[:user_id] || @current_user.id
    @participationsParams[:event_id] = @participationsParams[:event_id] || @event.id
    @participationsParams[:fee_id] = @participationsParams[:fee_id] || @fee.id
    @participationsParams[:fee_code_id] = @participationsParams[:fee_code_id] || @code.id unless @fee.public_fee
    @participation = @event.participations.new(@participationsParams)
    if @participation.save
      success_response(@participation)
      return
    else
      raise InternalServerError, record: @participation
    end
  end
end
