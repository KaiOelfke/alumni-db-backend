class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    include ActionController::StrongParameters
    include DeviseTokenAuth::Concerns::SetUserByToken

    before_action :configure_permitted_parameters, if: :devise_controller?

    respond_to :json

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) << :username
    end
end

