class Subscriptions::PlansController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = current_user

    if @user.is_super_user
      render json: Subscriptions::Plan.all
    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end

  end


  def show
    @user = current_user

    if @user.is_super_user
      @plan = Subscriptions::Plan.find_by_id(params[:id])

      if @plan
        render json: {
          status: 'success',
          data: @plan.to_json()
        }, status: 200
      else
        render json: {
          status: 'error',
          error: ["plan not found"]
        }, status: 404
      end

    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end

  end


  def create
    @user = current_user

    if @user.is_super_user

      @plan = Subscriptions::Plan.new(plan_create_params)
      if params[:default]
        Subscriptions::Plan.where(default: true).update_all(default: false)
        puts Subscriptions::Plan.all.to_json
      end
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
    @plan = Subscriptions::Plan.find_by_id(params[:id])

    if @user.is_super_user
      if @plan

        if params[:plan] and params[:plan][:default]
          Subscriptions::Plan.where(default: true).update_all(default: false)
        end


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
          error: ["plan not found"]
        }, status: 404
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
    @plan = Subscriptions::Plan.find_by_id(params[:id])
    if @user.is_super_user

      if @plan
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
          error: ["plan not found"]
        }, status: 404
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
        params.require(:plan).permit(:name, :description, :price, :default)
    end

    def plan_update_params
        params.require(:plan).permit(:name, :description, :price, :default)
    end

end