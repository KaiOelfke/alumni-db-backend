class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController

  def create
    @resource            = resource_class.new(sign_up_params)
    @resource.uid        = sign_up_params[:email]
    @resource.provider   = "email"
    @resource.registered = true
    @resource.confirmed_email = false
    @resource.completed_profile = false

    # success redirect url is required
    unless params[:confirm_success_url]
      return render json: {
        status: 'error',
        data:   @resource,
        errors: ["Missing `confirm_success_url` param."]
      }, status: 403
    end

    begin
      # override email confirmation, must be sent manually from ctrl
      User.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save
        # send email in seperate thread
        Thread.new do
          # user will require email authentication
          @resource.send_confirmation_instructions({
            client_config: params[:config_name],
            redirect_url: params[:confirm_success_url]
          })
        end

        # email auth has been bypassed, authenticate user
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }

        @resource.save!

        update_auth_header

        render json: {
          status: 'success',
          data:   @resource.as_json()
        }
      else
        clean_up_passwords @resource
        render json: {
          status: 'error',
          data:   @resource,
          errors: @resource.errors.to_hash.merge(full_messages: @resource.errors.full_messages)
        }, status: 403
      end
    rescue ActiveRecord::RecordNotUnique
      clean_up_passwords @resource
      render json: {
        status: 'error',
        data:   @resource,
        errors: ["An account already exists for #{@resource.email}"]
      }, status: 403
    end
  end

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
=begin
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
=end
  def destroy
    super
  end

  def sign_up_params
    params.permit(devise_parameter_sanitizer.for(:sign_up))
  end

  def account_update_params
    params.permit(devise_parameter_sanitizer.for(:account_update))
  end

end
