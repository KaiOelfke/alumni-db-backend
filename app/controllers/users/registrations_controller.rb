class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController

  def create
    @resource            = resource_class.new(sign_up_params)
    @resource.provider   = "email"

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      @resource.email = sign_up_params[:email].try :downcase
    else
      @resource.email = sign_up_params[:email]
    end

    # give redirect value from params priority
    @redirect_url = params[:confirm_success_url]

    # fall back to default value if provided
    @redirect_url ||= DeviseTokenAuth.default_confirm_success_url

    # success redirect url is required
    if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
      return render_create_error_missing_confirm_success_url
    end

    # if whitelist is set, validate redirect_url against whitelist
    if DeviseTokenAuth.redirect_whitelist
      unless DeviseTokenAuth.redirect_whitelist.include?(@redirect_url)
        return render_create_error_redirect_url_not_allowed
      end
    end

    begin
      # override email confirmation, must be sent manually from ctrl
      resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save
        yield @resource if block_given?

        # email auth has been bypassed, authenticate user
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }

        @resource.save!

        update_auth_header
        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    rescue ActiveRecord::RecordNotUnique
      clean_up_passwords @resource
      render_create_error_email_already_exists
    end
  end

end
=begin

  def update
    puts params
    if @resource
      if @resource.send(resource_update_method, account_update_params)
        yield @resource if block_given?
        render_update_success
      else
        render_update_error
      end
    else
      render_update_error_user_not_found
    end
  end
  def update
      return
      puts 'asdjkhjlaskdljaskdjlaksljaskaljskdalsjdkaljsdklkj'
      if @resource
        if params.has_key?('file')
          puts 'aslkjdjkalslkd'
          params[:avatar] = params['file'] 
          params.delete('file')
        end
        puts params.has_key?('file')
        puts params.has_key?(:file)
        puts params[:file]
        puts params
        puts account_update_params
        if @resource.update_attributes(account_update_params)
          render json: {
            status: 'success',
            data:   @resource.as_json
          }
        else
          render json: {
            status: 'error',
            errors: @resource.errors
          }, status: 403
        end
      else
        render json: {
          status: 'error',
          errors: ["User not found."]
        }, status: 404
      end    
  end
  def destroy
    super
  end

  def sign_up_params
    params.permit(devise_parameter_sanitizer.for(:sign_up))
  end

  def account_update_params
    params.permit(devise_parameter_sanitizer.for(:account_update))
  end
=end



