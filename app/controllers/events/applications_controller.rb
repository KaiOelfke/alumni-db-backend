#The naming is a bit bad here. Ideas?
#This controller is about applications to participate at an event.
#Not to confuse with the generic ApplicationController in a sense of 
#apps or program or application.

class Events::ApplicationsController < ApplicationController

  before_action :authenticate_user!

  def get_user_application
    validate_request
    @current_user = current_user
    application = Events::Application
                      .where(user_id: @current_user.id, event_id: @event.id).take
    if application
      success_response(application)
    else 
      raise NotFound, errors: ['application not found']
    end
  end

  #For super user / event admins
  def index
    validate_request
    @current_user = current_user
    unless @current_user.is_super_user
      raise Forbidden
    end
    applications = Events::Application.where(event_id: @event.id)
    success_response(applications)
  end

  def show
    @current_user = current_user
    unless @current_user.is_super_user
      raise Forbidden
    end
    unless params[:id]
      raise BadRequest, errors: ['id is required']
    end
    unless params[:event_id]
      raise BadRequest, errors: ['event_id is required']
    end 
    application = Events::Application.find_by_id( params[:id])
    success_response(application)
  end

  #User applies for an event with this
  def create
    validate_request
    @current_user = current_user
    applications = Events::Application.where(event_id: @event.id, user_id: @current_user.id)
    if applications.length > 0
      raise BadRequest, errors: ['user already applied']
    end
    newApplication = application_params
    newApplication['event_id'] = @event.id
    newApplication['user_id'] = @current_user.id    
    @application = Events::Application.new(newApplication)
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
        raise NotFound, errors: ['event not found']
      end
      unless @event.with_application? or @event.with_payment_application?
        raise BadRequest, errors: ['event type is without application']
      end
      unless @event.published?
        raise BadRequest, errors: ['event is not published']
      end
    end

    def application_params
    params.require(:application).permit(:motivation, :cv_file)
  end

end
