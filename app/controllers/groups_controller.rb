class GroupsController < ApplicationController

  before_action :authenticate_user!

  def users
    @memberships = Group.find(params[:id]).memberships.includes(:user)

    @result = []
    @memberships.each do |membership|
      @result.push({membership: membership.as_json(), user: membership.user.as_json()})
    end
    
    render json: @result
  end

  def index
    @groups = Group.all

    render json: @groups
  end

  def create
    @user = current_user

    if @user.is_super_user
      @group = Group.new(group_create_params)

      if @group.save
        render json: {
          status: 'success',
          data:   @group.as_json()
        }
      else
        render json: {
          status: 'error',
          errors: @group.errors
        }, status: 403
      end

    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end

  end

  def update
    @user = current_user
    @group = Group.find(params[:id])
    #Group.includes(:memberships, :users).find(params[:id]).
    #@group.users
    @membership = @user.memberships.find_by_group_id(params[:id])

    if @user.is_super_user or @membership.is_admin 
      if @group.update(group_update_params)
        render json: {
          data: @group.as_json(),
          status: 'success'
        }
      else
        render json: {
          status: 'error',
          errors: @group.errors
        }, status: 403
      end
    else
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end 

  end

  def show
    @group = Group.find(params[:id])
    render json: @group
  end

  def destroy
    @user = current_user
    @group = Group.find(params[:id])
    if @user.is_super_user

      if @group.destroy
        render json: {
          status: 'success'
        }
      else
        render json: {
          status: 'error',
          errors: @group.errors
        }, status: 403
      end

    else 
      render json: {
        status: 'error',
        errors: ["not authourized"]
      }, status: 403
    end

  end

  private 

    def group_create_params
        params.require(:group).permit(:description, :picture, :name, :group_email_enabled)
    end 

    def group_update_params
        params.require(:group).permit(:description, :picture, :name, :group_email_enabled)
    end   

end
