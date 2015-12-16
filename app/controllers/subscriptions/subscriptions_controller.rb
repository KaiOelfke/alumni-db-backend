class Subscriptions::SubscriptionsController < ApplicationController

  before_action :authenticate_user!

  def show
    @user = current_user
    if @user.subscription_id
    	@subscription = @user.subscription
    	@new_subscription = Braintree::Subscription.find(@subscription.braintree_new_subscription_id)
    	@old_subscription = Braintree::Subscription.find(@subscription.braintree_old_subscription_id)

    	if @new_subscription.success? and @new_subscription.status == Braintree::Subscription::Status::active
    		  
    		  render json: {
		          status: 'success',
		          data:   @new_subscription.slice(:status, :billing_period_start_date, :billing_period_end_date)
		      }, status: 404
    	elsif (@old_subscription.success? and @old_subscription.status == Braintree::Subscription::Status::active)
    		  
    		  render json: {
		          status: 'success',
		          data:   @old_subscription.slice(:status, :billing_period_start_date, :billing_period_end_date)
		      }, status: 404    	
    	else 
	      render json: {
	          status: 'error',
	          errors: ['subscription is not vaild']
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
    if params[:subscription][:plan_id]
    	@plan = Subscriptions::Plan.find(params[:subscription][:plan_id]) 
    end

    if params[:subscription][:discount_id]
    	@discount = Subscriptions::Discount.find(params[:subscription][:discount_id])
    end    

    @nonce_from_the_client = params[:subscription][:payment_method_nonce]
    puts @nonce_from_the_client
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
    		(@new_subscription and (@new_subscription.status == Braintree::Subscription::Status::Canceled or
    		@new_subscription.status == Braintree::Subscription::Status::Expired)))

		  if @plan
		  	puts @customer
		  	puts "asdasds"
		  	p @customer.methods.sort
		  	puts "asdasds"

		  	puts @customer.default_payment_method
		  	puts "asdasds"

		  	puts @customer.payment_methods
		  	@subscriptionRequest = {
				  :payment_method_token => @customer.payment_methods[0].token,
				  :plan_id =>  @plan.braintree_plan_id
				}

				if @discount and @plan.id == @discount.plan_id
			  	params[:subscription][:discount_id] = @discount.id					
					@subscriptionRequest[:discounts] = {
						:add => [
					      {
					        :inherited_from_id => @discount.braintree_discount_id
					      }
					    ]
					}
				end

			  @_subscription = Braintree::Subscription.create(@subscriptionRequest)

			  if @_subscription.success?
			  	params[:subscription][:braintree_new_subscription_id] = @_subscription.subscription.id
			  	params[:subscription][:braintree_old_subscription_id] = @_subscription.subscription.id			  	
			  	params[:subscription][:user_id] = @user.id
			  	params[:subscription][:plan_id] = @plan.id
			  	params[:subscription] = params[:subscription].except(:payment_method_nonce)

		      @user.subscription = Subscriptions::Subscription.new(subscription_create_params)
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
    @plan = Subscriptions::Plan.find(params[:subscription][:plan_id]) 

    if @user.subscription and @user.customer_id and @plan
		  
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
    if @subscription
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
    render json: {client_token: @client_token}
  end

  private

    def subscription_create_params
        params.require(:subscription).permit( :plan_id, :braintree_old_subscription_id,
        :braintree_new_subscription_id, :user_id, :discount_id, :payment_method_nonce)
    end

    def subscription_update_params
        params.require(:subscription).permit(:plan_id)
    end  

end