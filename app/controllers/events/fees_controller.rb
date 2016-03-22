class Events::FeesController < ApplicationController
  before_action :authenticate_user!

  def index
    #Returns all fees for one specific event, not all fees for all events
    params.require(:fee).require(:event_id)
    @permitted = params.require(:fee).permit(:event_id)

    unless @permitted.permitted?
        render json: {
          status: 'error',
          errors: ['event_id is required']
        }, status: 400
        return
    end

    
    @event = Event.find_by_id(params[:fee][:event_id])

    unless @event
      render json: {
          status: 'error',
          errors: ["event not found"]
        }, status: 404
        return
    end
    
    @current_user = current_user

    if @current_user.is_super_user or @event.published
      render json: {
          status: 'success',
          data: event.fees.as_json()
        }, status: 200
    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end
  end

  def show
    @fee = Fee.find_by_id(params[:id])
    @current_user = current_user

    if @fee 
      if @fee.event.published or current_user.is_super_user
        render json: {
          status: 'success',
          data: @fee.as_json()
        }, status: 200
      else
        render json: {
          status: 'error',
          errors: ["not authourized"]
        }, status: 403
      end
    else
      render json: {
        status: 'error',
        data: ["fee not found"]
      }, status: 404
    end
  end

  def update

    @user = current_user
    @fee = Fee.find_by_id(params[:id])

    if @user.is_super_user
      if @fee
        if @fee.update(fee_update_params)
          render json: {
            data: @fee.as_json(),
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @fee.errors
          }, status: 500
        end
      else
          render json: {
            status: 'error',
            errors: ["fee not found"]
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

      @fee = Fee.new(fee_create_params)

      if @fee.save
        render json: {
          status: 'success',
          data:   @fee.as_json()
        }, status: 200
      else
        render json: {
          status: 'error',
          errors: @fee.errors
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
    @fee = Fee.find_by_id(params[:id])
    if @user.is_super_user
      if @fee
          @fee.delete_flag = true
          if @fee.save
            render json: {
              status: 'success',
              data: @fee.as_json
            }, status: 200
          else
            render json: {
              status: 'error',
              errors: @fee.errors
            }, status: 500
          end
      else
          render json: {
            status: 'error',
            errors: ["fee not found"]
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

    def fee_update_params
        params.require(:fee).permit(:name, :deadline, :price)
    end

    def fee_create_params
        params.require(:fee).permit(:name, :deadline, :price, :event_id)
    end
end
