class Events::FeeCodesController < ApplicationController

  before_action :authenticate_user!

  def index
    @current_user = current_user
    if @current_user.is_super_user
      
      @feeCodes = Events::FeeCode.all

    else 
      raise Forbidden
    end
    
    success_response( @feeCodes)
  end


  # def all_fees_for_event

  #   @current_user = current_user
  #   if @current_user.is_super_user
  #     @feeCodes = Events::Event.find_by_id(params[:event_id]).fees.joins(:fee_codes)
  #   else 
  #     raise Forbidden
  #   end
    
  #   success_response( @feeCodes)
  # end

  #More like all codes for event
  def all_codes_for_event

    @current_user = current_user
    if @current_user.is_super_user
      @event = Events::Event.find_by_id(params[:event_id])
      if @event
        @feeCodes = Events::FeeCode.joins(:fee).where(:fees => {:event_id => @event.id})
      else
        raise NotFound
      end
    else 
      raise Forbidden
    end
    
    success_response( @feeCodes)
  end

  #Validates code
  def validate_code
    
    @event = Events::Event.find_by_id(params[:event_id])
    unless @event
      raise NotFound, record: @event
    end

    if @event.without_application_payment?
       raise BadRequest, errors: ['event type does not support codes']
    end

    @code = Events::FeeCode.where( code: params[:code]).take
    
    unless @code
      raise NotFound, record: @code
    end

    if @code.used_flag
      raise NotFound, errors: ["code is already used"]
    end

    if @event.with_application
      success_response({ valid: true })
    end

    if @code.fee
      success_response ({valid: true,
                        fee: @fee})
    else
      if @event.with_payment
        raise InternalServerError, errors: ['special fee is missing']
      end
      if @event.with_payment_application
        success_response ({valid: true})
      end
    end
  end



  def show
    @current_user = current_user

    if @current_user.is_super_user

      if /\A\d+\z/.match(params[:id])
        @feeCode = Events::FeeCode.find_by_id(params[:id])
      else
        @feeCode = Events::FeeCode.where( code: params[:id]).take
      end

      if @feeCode
        success_response( @feeCode)
      else
        raise NotFound
      end

    else
      raise Forbidden
    end

  end

  def create
    @current_user = current_user

    if @current_user.is_super_user

        @feeCode = Events::FeeCode.new(create_feecode_params);

        if @feeCode.save
          success_response( @feeCode)
        else
          raise InternalServerError, record: @feeCode
        end

    else 
      raise Forbidden
    end

  end

  # def update
  #   @current_user = current_user

  #   if @current_user.is_super_user

  #     @feeCode = Events::FeeCode.where( "code = ? OR id = ?",
  #                                       params[:code],
  #                                       params[:id]).take
  #     if @feeCode
  #       if @feeCode.update(update_feecode_params)
  #         success_response( @feeCode)
  #       else
  #         raise InternalServerError, record: @feeCode
  #       end        
  #     else 
  #       raise NotFound
  #     end

  #   else
  #     raise Forbidden
  #   end

  # end

  def destroy
    @current_user = current_user

    if @current_user.is_super_user
      
      @feeCode = Events::FeeCode.where( "code = ? OR id = ?",
                                        params[:code],
                                        params[:id]).take

      if @feeCode
        @feeCode.delete_flag = true

        if @feeCode.save
          success_response( @feeCode)
        else
          raise InternalServerError, record: @feeCode
        end

      else
        raise NotFound
      end
    else
      raise Forbidden
    end

  end

  private

    def create_feecode_params
        params.require(:fee_code).permit(:user_id, :fee_id)
    end

    # def update_feecode_params
    #     params.require(:fee_code).permit(:delete_flag)
    # end
end
