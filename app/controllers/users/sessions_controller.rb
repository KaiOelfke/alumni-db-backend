class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  prepend_before_filter :require_no_authentication, :only => [:create ]
  include Devise::Controllers::Helpers


  def create
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    render :status => 200, :json => { :success => true, :info => "Logged in", :user => current_user }
  end

  def destroy
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_out
    render :status => 200, :json => { :success => true, :info => "Logged out", :csrfParam => request_forgery_protection_token, :csrfToken => form_authenticity_token }
  end

  def failure
    render :status => 401, :json => { :success => false, :info => "Login Credentials Failed" }
  end


  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
