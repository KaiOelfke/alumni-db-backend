class Subscriptions::SubscriptionsController < ApplicationController

  before_action :authenticate_user!

  def show
    @current_user = current_user
    @user = User.find_by_id(params[:id])
    unless @user
      render json: {
          status: 'error',
          errors: ['user not found']
      }, status: 404
      return
    end

    if ((@current_user.is_super_user and @user.subscription_id) or
       (@user and @user.id ==  @current_user.id and @user.subscription_id))

      @subscription = @user.subscription
      if @subscription
          render json: {
              status: 'success',
              data:   @subscription.to_json
          }, status: 200
      else
        render json: {
            status: 'error',
            errors: ['subscription is not vaild']
        }, status: 404
      end
    else
      render json: {
          status: 'error',
          errors: ['no subscription found']
      }, status: 404
    end

  end




  # create subscirption 
  # params:
  #    user_id required for paying in cash and the current user musst be super user
  #    payment_method_nonce optional only for paying in cash and the current user is super user
  #    plan_id optional only if a default plan exists
  #    discount_id optional and should be associated with the plan
  #
  def create
    @current_user = current_user
    @nonce_from_the_client = params[:subscription][:payment_method_nonce]
    @user_id = params[:subscription][:user_id]

    if params[:subscription][:discount_id]
      @discount = Subscriptions::Discount.find_by_id(params[:subscription][:discount_id])
      unless @discount
        render json: {
          status: 'error',
          errors: ["discount not found"]
        }, status: 404
        return
      end
    end

    if params[:subscription][:plan_id]
      @plan = Subscriptions::Plan.find_by_id(params[:subscription][:plan_id])
    else
      @plan = Subscriptions::Plan.find_by default: true
    end

    unless @plan
      render json: {
        status: 'error',
        errors: ["plan not found"]
      }, status: 404
      return
    end

    #
    # pay in cash
    # super user feature
    #
    if @user_id and not @nonce_from_the_client and @current_user.is_super_user?
      @user = User.find(@user_id)
      unless @user
        render json: {
          status: 'error',
          errors: ["user not found"]
        }, status: 404
        return
      end      


      if @user.subscription_id?
        render json: {
            status: 'error',
            errors: ['the user have already a vaild subscription']
        }, status: 500
        return
      end

      params[:subscription][:plan_id] = @plan.id
      params[:subscription] = params[:subscription].except(:payment_method_nonce)

      @user.subscription = Subscriptions::Subscription.new(subscription_create_params)
      @user.subscription_id = @user.subscription.id
      if @user.save
        render json: {
          status: 'success',
          data:  @user.as_json()
        }
      else
        render json: {
          status: 'error',
          errors: @user.errors
        }, status: 403
      end
      return

    #
    # normal paying process
    #
    elsif @nonce_from_the_client

      if @current_user.subscription_id?
        render json: {
            status: 'error',
            errors: ['the user have already a vaild subscription']
        }, status: 500
        return
      end


      # create braintree customer if no customer_id for the user exists
      unless @current_user.customer_id?
        @customer = Braintree::Customer.create(
          :first_name => @current_user.first_name,
          :last_name => @current_user.last_name,
          :credit_card => {
            :payment_method_nonce => @nonce_from_the_client,
            :options => {
              :verify_card => true
            }
          }
        )

        if @customer.success?
          @customer = @customer.customer
          @current_user.customer_id = @customer.id
        else
          render json: {
              status: 'error',
              errors: @customer.errors
          }, status: 500
          return
        end
      else
        @customer = Braintree::Customer.find(@current_user.customer_id)
        @updatePaymentMethodResult = Braintree::PaymentMethod.update(
          @customer.payment_methods[0].token, # default payment method
          :payment_method_nonce => @nonce_from_the_client,
          :options => {
            :verify_card => true
          }
        )

        unless @updatePaymentMethodResult.success? 
          render json: {
              status: 'error',
              errors: @updatePaymentMethodResult.errors
          }, status: 500
          return
        end

      end

      @transactionRequest = {
        :amount => @plan.price,
        :customer_id => @current_user.customer_id,
        :options => {
          :store_in_vault_on_success => true
        },
        :payment_method_token => @customer.payment_methods[0].token
      }

      if @discount and @plan.id == @discount.plan_id
        params[:subscription][:discount_id] = @discount.id
        @transactionRequest[:amount] -= @discount.price

        if @transactionRequest[:amount] < 0
          @transactionRequest[:amount] = 0
        end
      end

      @transaction = Braintree::Transaction.sale(@transactionRequest)

      if @transaction.success?
        params[:subscription][:plan_id] = @plan.id
        params[:subscription][:braintree_transaction_id] = @transaction.transaction.id
        params[:subscription] = params[:subscription].except(:user_id,:payment_method_nonce)

        @current_user.subscription = Subscriptions::Subscription.new(subscription_create_params)

        if @current_user.save
          render json: {
            status: 'success',
            data:   @current_user.token_validation_response
          }
        else
          render json: {
            status: 'error',
            errors: @current_user.errors
          }, status: 403
        end

      else
        render json: {
          status: 'error',
          errors: @transaction.errors
        }, status: 500

      end


    else
        render json: {
            status: 'error',
            errors: ['nonce token isn\'t provided']
        }, status: 404
        return
    end
      
      
  end

  def destroy
    @current_user = current_user

    @subscription = Subscriptions::Subscription.find_by_id(params[:id])

    if @subscription
      @user = User.find_by_subscription_id( @subscription.id)

      if @current_user.is_super_user or @current_user.id == @user.id

        if @user.subscription.destroy
          render json: {
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @subscription.errors
          }, status: 403
        end
      else
        render json: {
          status: 'error',
          errors: ["not authourized"]
        }, status: 403
      end

    else
      render json: {
        status: 'error',
        errors: ["subscription not found"]
      }, status: 404
    end


  end

  def client_token
    @client_token = Braintree::ClientToken.generate
    render json: {clientToken: @client_token}
  end

  private

    def subscription_create_params
        params.require(:subscription).permit( :plan_id, :braintree_transaction_id,
         :discount_id, :payment_method_nonce)
    end

end