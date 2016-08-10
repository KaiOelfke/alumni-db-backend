class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, on: :update

  # GET /users
  # GET /users.json
  def index
    @current_user = current_user
    page = params[:page] 
    filter = params[:filter]
    limit = params[:limit]
    
    unless @current_user.is_super_user
      raise Forbidden
    end

    if page == "0" or not (is_integer?(page)) or 
       limit == "0" or not (is_integer?(limit))
      raise BadRequest, errors: ['params are wrong']
    end
    
    @count = 0

    if filter.nil? or filter == ""
      @users = User.paginate(:page => params[:page], :per_page => params[:limit])
      @count = User.count
    else
      @users = User.search(params[:filter])
                   .paginate(:page => params[:page], :per_page => params[:limit])
      @count = User.search(params[:filter]).count
    end

    render json: {
      status: 'success',
      data: @users,
      count: @count
      }, status: 200
  end


  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    if @user
        render json: {
          status: 'success',
          data: @user.as_json()
        }, status: 200
    else
        render json: {
          status: 'error',
          error: ["user not found"]
        }, status: 404
    end
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
        }, status: 200
      else
        render json: {
          status: 'error',
          errors: @resource.errors
        }, status: 500
      end
    else
      render json: {
        status: 'error',
        errors: ["User not found."]
      }, status: 404
    end
  end

  def is_integer? string
    true if Integer(string) rescue false
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
