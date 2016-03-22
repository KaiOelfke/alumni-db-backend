class Subscriptions::DiscountsController < ApplicationController

  before_action :authenticate_user!

  def index
    @user = current_user

    if @user.is_super_user
      render json: Subscriptions::Discount.all
    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end
  end

  # validates discount code and returns discount id
  def check
    params.require(:discount).require(:code)
    params.require(:discount).require(:plan_id)

    @permitted = params.require(:discount).permit(:code, :plan_id)

    unless @permitted.permitted?
        render json: {
          status: 'error',
          errors: ['code and plan_id are required']
        }, status: 400
        return
    end


    @discount = Subscriptions::Discount.find_by(:code => params[:discount][:code])

    unless @discount
        render json: {
          status: 'error',
          errors: ["discount not found"]
        }, status: 404
        return
    end

    if @discount.plan and @discount.plan.id == params[:discount][:plan_id]
        render json: {
          status: 'success',
          data: @discount.as_json()
        }, status: 200
    else
        render json: {
          status: 'error',
          errors: ["plan_id does not match"]
        }, status: 400
    end

  end


  def show
    @user = current_user

    if @user.is_super_user
      @discount = Subscriptions::Discount.find_by_id(params[:id])
      if @discount
        render json: {
          status: 'success',
          data: @discount.as_json()
        }, status: 200
      else
        render json: {
          status: 'error',
          data: @discount.errors
        }, status: 500
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

      @discount = Subscriptions::Discount.new(discount_create_params)

      if @discount.save
        render json: {
          status: 'success',
          data:   @discount.as_json()
        }, status: 200
      else
        render json: {
          status: 'error',
          errors: @discount.errors
        }, status: 500
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
    @discount = Subscriptions::Discount.find_by_id(params[:id])

    if @user.is_super_user
      if @discount
        if @discount.update(discount_update_params)
          render json: {
            data: @discount.as_json(),
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @discount.errors
          }, status: 500
        end
      else
          render json: {
            status: 'error',
            errors: ["discount not found"]
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
    @discount = Subscriptions::Discount.find_by_id(params[:id])
    if @user.is_super_user
      if @discount
          @discount.delete_flag = true
          if @discount.save
            render json: {
              status: 'success',
              data: @discount.as_json
            }, status: 200
          else
            render json: {
              status: 'error',
              errors: @discount.errors
            }, status: 500
          end
      else
          render json: {
            status: 'error',
            errors: ["discount not found"]
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

    def discount_create_params
        params.require(:discount).permit(:code, :name, :description, :price, :expiry_at, :plan_id)
    end

    def discount_update_params
        params.require(:discount).permit(:code, :name, :description, :price, :expiry_at)
    end

end
