class Users::SessionsController < DeviseTokenAuth::SessionsController

  def create
    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      email = resource_params[:email].downcase
    else
      email = resource_params[:email]
    end

    q = "uid='#{email}' AND provider='email'"

    if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
      q = "BINARY uid='#{email}' AND provider='email'"
    end

    @resource = resource_class.where(q).first


    if @resource and valid_params? and @resource.valid_password?(resource_params[:password])
      # create client id
      @client_id = SecureRandom.urlsafe_base64(nil, false)
      @token     = SecureRandom.urlsafe_base64(nil, false)

      @resource.tokens[@client_id] = {
        token: BCrypt::Password.create(@token),
        expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
      }

      @resource.save

      @resource.skip_confirmation!

      sign_in(:user, @resource, store: false, bypass: false)
          
      render json: {
        data: @resource.as_json(
          include: {statuses: {only: :kind}},
          except: [:tokens, :created_at, :updated_at
        ])
      }

    else
      render json: {
        errors: ["Invalid login credentials. Please try again."]
      }, status: 401
    end
  end

  def destroy
    super
  end

  def valid_params?
    resource_params[:password] && resource_params[:email]
  end

  def resource_params
    params.permit(devise_parameter_sanitizer.for(:sign_in))
  end

end
