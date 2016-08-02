class Events::FeesController < ApplicationController
  before_action :authenticate_user!

  def index
    #Returns all fees for one specific event, not all fees for all events

=begin
    ## wired way to do it .. you cannt fee jsonbonject with get http call
    ## should be tested ..
    params.require(:fee).require(:event_id)
    @permitted = params.require(:fee).permit(:event_id)

    unless @permitted.permitted?
        render json: {
          status: 'error',
          errors: ['event_id is required']
        }, status: 400
        return
    end

=end
    unless params[:event_id]
        render json: {
          status: 'error',
          errors: ['event_id is required']
        }, status: 400
        return
    end

    @current_user = current_user

    if @current_user.is_super_user

      @event = Events::Event.find_by_id(params[:event_id])

      if @event
        render json: {
            status: 'success',
            data: @event.fees.as_json()
          }, status: 200        
      else 
        render json: {
            status: 'error',
            errors: ["event not found"]
          }, status: 404
      end

    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end
  end

  def show
    @current_user = current_user

    if @current_user.is_super_user 
      @fee = Events::Fee.find_by_id(params[:id])
      if @fee
        render json: {
          status: 'success',
          data: @fee.as_json()
        }, status: 200
      else
        render json: {
          status: 'error',
          data: ["fee not found"]
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

    if @user.is_super_user

      @fee = Events::Fee.find_by_id(params[:id])
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

      @fee = Events::Fee.new(fee_create_params)

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
    @fee = Events::Fee.find_by_id(params[:id])
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
        params.require(:fee).permit(:name, :deadline, :price, :early_bird_fee, :honoris_fee)
    end

    def fee_create_params
        params.require(:fee).permit(:name, :deadline, :price, :event_id, :early_bird_fee, :honoris_fee)
    end
end
