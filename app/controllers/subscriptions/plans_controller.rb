class Subscriptions::PlansController < ApplicationController

  before_action :authenticate_user!

  def index
    #braintree 
    if params['btree']?
      @plans = Braintree::Plan.all
    else
      @plans = Discount.all
    end

    render json: @plans
  end



  def create
    @user = current_user

    if @user.is_super_user
      @plan = Plan.new(plan_create_params)

      if @plan.save
        render json: {
          status: 'success',
          data:   @plan.as_json()
        }
      else
        render json: {
          status: 'error',
          errors: @plan.errors
        }, status: 403
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
    @plan = plan.find(params[:id])

    if @user.is_super_user 
      if @plan.update(plan_update_params)
        render json: {
          data: @plan.as_json(),
          status: 'success'
        }
      else
        render json: {
          status: 'error',
          errors: @plan.errors
        }, status: 403
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
    @plan = plan.find(params[:id])
    if @user.is_super_user
      @plan.delete_flag = true
      if @plan.save
        render json: {
          status: 'success'
        }
      else
        render json: {
          status: 'error',
          errors: @plan.errors
        }, status: 403
      end

    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end
  end

  private

    def plan_create_params
        params.require(:plan).permit(:name, :description, :created_at)
    end

    def plan_update_params
        params.require(:plan).permit(:name, :description, :expiry_at)
    end

end