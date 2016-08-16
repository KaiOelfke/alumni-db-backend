class Events::FeesController < ApplicationController
  before_action :authenticate_user!

  def index
    #Returns all fees for one specific event, not all fees for all events
    validate_request
    unless params[:event_id]
      raise BadRequest, errors: ['event_id is required']
    end
    @event = Events::Event.find_by_id(params[:event_id])
    validate_event
    success_response(@event.fees)
  end

  def show
    validate_request
    @fee = Events::Fee.find_by_id(params[:id])
    if @fee
      success_response (@fee)
    else
      raise NotFound, errors: ['fee not found']       
    end
  end

  def update
    validate_request
    @fee = Events::Fee.find_by_id(params[:id])
    if @fee
      if @fee.update(fee_update_params)
        success_response( @fee )
      else 
        raise InternalServerError, errors: @fee.errors
      end
    else
      raise NotFound, errors: ['fee not found']
    end
  end

  def create
    validate_request
    event_id = fee_create_params[:event_id]
    unless event_id
      raise BadRequest, errors: ['event_id is required']
    end
    @event = Events::Event.find_by_id(event_id)
    validate_event
    @fee = Events::Fee.new(fee_create_params)

      if @fee.save
        success_response (@fee)
      else
        raise InternalServerError, errors: @fee.errors
      end

  end

  def destroy
    validate_request
    @fee = Events::Fee.find_by_id(params[:id])
    if @fee
        @fee.delete_flag = true
        if @fee.save
          success_response (@fee)
        else
          raise InternalServerError, errors: @fee.errors
        end
    else
      raise NotFound, errors: ['fee not found']
    end
  end

  private

    def validate_request
      unless current_user.is_super_user
        raise Forbidden
      end
    end

    def validate_event
      unless @event
        raise NotFound, errors: ['event not found']
      end
      if @event.without_application_payment? or @event.with_application?
        raise BadRequest, errors: ['event is without payment']
      end
    end

    def fee_update_params
        params.require(:fee).permit(:name, :deadline, :price, :public_fee)
    end

    def fee_create_params
        params.require(:fee).permit(:name, :deadline, :price, :event_id, :public_fee)
    end
end
