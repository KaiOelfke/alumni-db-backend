class Users::ConfirmationsController < DeviseTokenAuth::ConfirmationsController

  before_action :authenticate_user!, :only => :create

  #GET /resource/confirmation/new
  #def new
  #   super
  #end

  #POST /resource/confirmation
  def create
      @resource = current_user

      unless params[:confirm_success_url]
        return render json: {
          status: 'error',
          data:   @resource,
          errors: ["Missing `confirm_success_url` param."]
        }, status: 403
      end

      unless @resource.confirmed?      
        return render json: {
          status: 'error',
          data:   @resource,
          errors: ["email already confirmed"]
        }, status: 403
      end
   
      errors = nil

      if @resource
        @resource.send_confirmation_instructions({
          redirect_url: params[:confirm_success_url],
          client_config: params[:config_name]
        })
      else
        errors = ["Unable to find user with email '#{email}'."]
      end

      if errors
        render json: {
          success: false,
          errors: errors
        }, status: 400
      else
        render json: {
          status: 'success',
          data:   @resource.as_json
        }
      end
  end

  #GET /resource/confirmation?confirmation_token=abcdef
  #def show
  #   super
  #end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
