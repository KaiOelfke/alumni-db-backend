class Subscriptions::SubscriptionsController < ApplicationController

  before_action :authenticate_user!

  def show
    @user = current_user
    if @user.subscription_id?
    	@subscription = @user.subscription
    	@new_subscription = Braintree::Subscription.find(@subscription.braintree_new_subscription_id)
    	@old_subscription = Braintree::Subscription.find(@subscription.braintree_old_subscription_id)

    	if (@new_subscription.success? and @new_subscription.status == Braintree::Subscription::Status::active)
    		  @new_subscription.slice(:status, :billing_period_start_date, :billing_period_end_date)
    		  render json: {
		          status: 'success',
		          data:   @user.as_json()
		      }, status: 404
    	elsif (@old_subscription.success? and @old_subscription.status == Braintree::Subscription::Status::active)
    		  @old_subscription.slice(:status, :billing_period_start_date, :billing_period_end_date)
    		  render json: {
		          status: 'success',
		          data:   @user.as_json()
		      }, status: 404    	
    	else 
	      render json: {
	          status: 'error',
	          errors: @customer.errors
	      }, status: 500
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
    @plan = Plan.find(params[:plan_id]) 
    @discount = Discount.find(params[:discount_id])

    @nonce_from_the_client = params[:payment_method_nonce]


    unless @user.customer_id?
    	@customer = Braintree::Customer.create(
			  :first_name => @user.first_name,
			  :last_name => @user.last_name,
			  :payment_method_nonce => @nonce_from_the_client
		  )

		  if @customer.success?
			  @user.customer_id = @customer.customer.id
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


    end

    if @user.subscription_id?
    	@subscription = @user.subscription
    	@new_subscription = Braintree::Subscription.find(@subscription.braintree_new_subscription_id)

    	if @new_subscription.success? and @new_subscription.status == Braintree::Subscription::Status::Active 
	      render json: {
	          status: 'error',
	          errors: @customer.errors
	      }, status: 500
	     	return
    	end
    end


    if (not @user.subscription_id? or
    		(@new_subscription? and (@new_subscription.status == Braintree::Subscription::Status::Canceled or
    		@new_subscription.status == Braintree::Subscription::Status::Expired)))

		  if @plan?

		  	@subscriptionRequest = {
				  :payment_method_token => @customer.customer.payment_methods[0].token,
				  :plan_id =>  @plan.braintree_plan_id
				}

				if @discount? and @plan.id == @discount.plan_id
					@subscriptionRequest[:discounts] = {
						:add => [
					      {
					        :inherited_from_id => @discount.braintree_discount_id
					      }
					    ]
					}

			  @_subscription = Braintree::Subscription.create(@subscriptionRequest)

			  if @_subscription.success?
			  	params[:braintree_new_subscription_id] = @_subscription.subscription.id
		      @user.subscription = Subscription.new(subscription_create_params)
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
	          errors: @_subscription.errors
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

  def update
    @user = current_user
    @plan = Plan.find(params[:plan_id]) 

    if @user.subscription? and @user.customer_id? and @plan?
		  
		  @_subscription = Braintree::Subscription.update(
			  :plan_id =>  @plan.braintree_plan_id,
			  :braintree_new_subscription_id => @user.subscription.braintree_new_subscription_id
		  )

		  if @_subscription.success?
		      if @user.subscription.update(subscription_update_params)
		        render json: {
		          data: @user.as_json(),
		          status: 'success'
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
          errors: @_subscription.errors
        }, status: 500
		  end


    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end
  end

  def destroy
    @user = current_user
    @subscription = @user.subscription
    if @subscription?
    	@new_subscription = Braintree::Subscription.find(@subscription.braintree_new_subscription_id)
    	@old_subscription = Braintree::Subscription.find(@subscription.braintree_old_subscription_id)

    	if (@new_subscription.status == Braintree::Subscription::Status::Canceled or
    		@new_subscription.status == Braintree::Subscription::Status::Expired)
        render json: {
          status: 'error',
          errors: ['subscription is already cancelled/expired']
        }, status: 500
     	else
	      @_subscription = Braintree::Subscription.cancel(@subscription.braintree_new_subscription_id)

	      if  @_subscription.success?
	      	if @new_subscription.status == Braintree::Subscription::Status::Active
	      		@subscription.braintree_old_subscription_id = @subscription.braintree_new_subscription_id
	        	@subscription.cancelled_at = @new_subscription.billing_period_end_date 
			      if @subscription.save
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
		          errors: ['subscription is already cancelled/expired']
		        }, status: 500
		      end
	      else
		        render json: {
		          status: 'error',
		          errors: @_subscription.errors
		        }, status: 500
	      end



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
  end

  private

    def subscription_create_params
        params.require(:subscription).permit(:user_id, :plan_id, :discount_id)
    end

    def subscription_update_params
        params.require(:subscription).permit(:plan_id)
    end  

end