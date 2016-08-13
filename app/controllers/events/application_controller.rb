#The naming is a bit bad here. Ideas?
#This controller is about applications to participate at an event.
#Not to confuse with the generic ApplicationController in a sense of 
#apps or program or application.

class Events::ApplicationController < ApplicationController

  before_action :authenticate_user!

  #For super user / event admins
  def index
    validate_request
    @current_user = current_user
    unless @current_user.is_super_user
      raise NotAuthorized
    end

    applications = Events:Application.where(:event_id => @event.id)
    success_response(applications)
  end

  #User applies for an event with this
  def create

    validate_request
    @current_user = current_user
    @application = Events::Application.where(:event_id => @event.id, :user_id => @current_user.id)

    if @application
      raise BadRequest, errors: ['user already applied']
    end

    @application = Events::Application.new(application_params)
    if @application.save
      success_response(@application)
    else
      raise InternalServerError, record: @application
    end

  end

  private

    def validate_request
      unless params[:event_id]
        raise BadRequest, errors: ['event_id is required']
      end

      @event = Events::Event.find_by_id( params[:event_id])

      unless @event
        raise NotFound, record: @event
      end

      unless @event.with_application? or @event.with_payment_application
        raise BadRequest, errors: ['event type is without application']
      end
    end

    def application_params
    params.require(:participation).permit(:user_id, :fee_id, :motivation, :cv_file)
  end

end
