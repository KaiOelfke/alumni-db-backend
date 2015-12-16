class Subscriptions::SubscriptionsController < ApplicationController

  before_action :authenticate_user!

  def show
    @user = current_user
    if @user.subscription_id
    	@subscription = @user.subscription
    	if @subscription
    		  render json: {
		          status: 'success',
		          data:   @subscription
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

  def create
    @user = current_user
    if params[:subscription][:plan_id]
    	@plan = Subscriptions::Plan.find(params[:subscription][:plan_id]) 
    end

    if params[:subscription][:discount_id]
    	@discount = Subscriptions::Discount.find(params[:subscription][:discount_id])
    end    

    if params[:subscription][:payment_method_nonce]
    	@nonce_from_the_client = params[:subscription][:payment_method_nonce]
    end

    unless @nonce_from_the_client
	      render json: {
	          status: 'error',
	          errors: ['nonce token isn\'t provided']
	      }, status: 500
	      return  	
    end

    unless @plan
    	@plan = Subscriptions::Plan.find_by default: true
    end

    unless @user.customer_id?
    	@customer = Braintree::Customer.create(
			  :first_name => @user.first_name,
			  :last_name => @user.last_name,
			  :payment_method_nonce => @nonce_from_the_client
		  )

		  if @customer.success?
			  @user.customer_id = @customer.customer.id
			  @customer = @customer.customer
	      unless @user.save
	        render json: {
	          status: 'error',
	          errors: @user.errors
	        }, status: 403
	        return
	      end
		  else
	      render json: {
	          status: 'error',
	          errors: @customer.errors
	      }, status: 500
	     	return
		  end
    else
    	@customer = Braintree::Customer.find(@user.customer_id)
    end

    if @user.subscription_id?
    	@subscription = @user.subscription

    	if @subscription.expiry_at.to_datetime >= Time.zone.now
	      render json: {
	          status: 'error',
	          errors: ['you have already a vaild subscription']
	      }, status: 500
	     	return
    	end
    end


    if (not @user.subscription_id? or
    		(@subscription and @subscription.expiry_at.to_datetime < Time.zone.now))

		  if @plan
		  	@transactionRequest = {
				  :amount => @plan.price,
				  :customer_id => @user.customer_id,
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
			  	params[:subscription][:user_id] = @user.id
			  	params[:subscription][:plan_id] = @plan.id
			  	params[:subscription][:expiry_at] = @plan.duration.month.from_now
			  	params[:subscription][:braintree_transaction_id] = @transaction.transaction.id
			  	params[:subscription] = params[:subscription].except(:payment_method_nonce)

		      @user.subscription = Subscriptions::Subscription.new(subscription_create_params)
			  	@user.subscription_id = @user.subscription.id
		      if @user.save
		        render json: {
		          status: 'success',
		          data:   @user.as_json()
		        }
		      else
		        render json: {
		          status: 'error',
		          errors: @user.errors
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
          errors: ["plan not found"]
        }, status: 404
			end
    
    else 
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end
  end




  #
  def client_token
    @client_token = Braintree::ClientToken.generate
    render json: {clientToken: @client_token}
  end

  private

    def subscription_create_params
        params.require(:subscription).permit( :plan_id, :braintree_transaction_id,
        :user_id, :discount_id, :expiry_at, :payment_method_nonce)
    end

    def subscription_update_params
        params.require(:subscription).permit(:plan_id)
    end  

end