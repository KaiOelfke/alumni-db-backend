class Subscriptions::DiscountsController < ApplicationController

  before_action :authenticate_user!

  def index
    #braintree 
    if params['btree']?
      @discount = Braintree::Discount.all
    else
      @discount = Discount.all
    end

    render json: @discounts

  end

  def create
    @user = current_user

    if @user.is_super_user
      @discount = Discount.new(discount_create_params)

      if @discount.save
        render json: {
          status: 'success',
          data:   @discount.as_json()
        }
      else
        render json: {
          status: 'error',
          errors: @discount.errors
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
    @discount = Discount.find(params[:id])

    if @user.is_super_user
      if @group.update(discount_update_params)
        render json: {
          data: @discount.as_json(),
          status: 'success'
        }
      else
        render json: {
          status: 'error',
          errors: @discount.errors
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
    @discount = Discount.find(params[:id])
    if @user.is_super_user
      @discount.delete_flag = true
      if @discount.save
        render json: {
          status: 'success'
        }
      else
        render json: {
          status: 'error',
          errors: @discount.errors
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

    def discount_create_params
        params.require(:discount).permit(:code, :name, :description, :expiry_at, :plan_id)
    end

    def discount_update_params
        params.require(:discount).permit(:code, :name, :description, :expiry_at)
    end

end
