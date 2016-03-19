class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, on: :update

  # GET /users
  # GET /users.json
  def index
    @current_user = current_user

    if @current_user.is_super_user
      @users = User.all
    else
      @users = User.completed_profile
    end
    


    render :json => @users.map { |user| 

      if @current_user.id != user.id and not @current_user.is_super_user
        user.as_json(:except => [:subscription_id]) 
      else
        user.as_json()
      end
    }

  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    render json: @user
  end

  def update
    @resource = current_user
      if @resource

        unless (@resource.completed_profile)

          @resource.completed_profile = true
          @resource.assign_attributes(account_update_params)

          unless @resource.valid?

            @resource.completed_profile = false
            render json: {
              status: 'error',
              errors: @resource.errors
            }, status: 403

            return
          end
        end

        if @resource.update(account_update_params)
          render json: {
            status: 'success',
            data:   @resource.as_json()
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


  def account_update_params
    params.permit(devise_parameter_sanitizer.for(:account_update))
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end
