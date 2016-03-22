class Events::EventsController < ApplicationController

  before_action :authenticate_user!

  def index
    @current_user = current_user

    if @current_user.is_super_user
      @events = Events::Event.all
    else
      @events = Events::Event.published
    end
  
    render json: {
        status: 'success',
        data: @events.as_json()
      }, status: 200
  end

  def show
    @event = Events::Event.find_by_id(params[:id])
    @current_user = current_user

    if @event
      if @current_user.is_super_user or @event.published
        render json: {
          status: 'success',
          data: @event.as_json()
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
          error: ["event not found"]
        }, status: 404
    end
  end

  def update
    @event = Events::Event.find_by_id(params[:id])
    @current_user = current_user

    if @current_user.is_super_user
      if @event
        if @event.update(event_params)
          render json: {
            data: @event.as_json(),
            status: 'success'
          }, status: 200
        else
          render json: {
            status: 'error',
            errors: @event.errors
          }, status: 500
        end
      else
        render json: {
          status: 'error',
          error: ["event not found"]
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
    @current_user = current_user

    if @current_user.is_super_user
        if Events::Event.create(event_params)
          render json: {
            data: @event.as_json(),
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @event.errors
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
    @current_user = current_user
    @event = Events::Event.find_by_id(params[:id])
    if @current_user.is_super_user

      if @event
        @event.delete_flag = true

        if @event.save
          render json: {
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @event.errors
          }, status: 500
        end
      else
        render json: {
          status: 'error',
          error: ["event not found"]
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

    def event_params
        params.require(:event).permit(:name, :description, :location, :dates, 
          :facebook_url, :published, :contact_email)
    end

end
