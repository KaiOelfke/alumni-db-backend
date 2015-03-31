class MembershipsController < ApplicationController

  before_action :authenticate_user!

  def create
    if params[:group_id] and params[:user_id]
      return render json: {
        status: 'error',
        errors: ["Missing param."]
      }, status: 403
    end

    @user = current_user
    @membership = @user.memberships.find_by(group_id: params[:group_id])
    @membership_params = membership_create_params
    @membership_params[:join_date] = Date.current

    @meb = Membership.new(@membership_params)

    if @meb.save
        render json: {
          status: 'success',
          data:   @meb.as_json()
        }
    else
        render json: {
          status: 'error',
          errors: @meb.errors
        }, status: 403
    end

  end

  def show
    @membership = Membership.find(params[:membership_id])
    if @membership
        render json: @membership        
    else
      render json: {
        status: 'error',
        errors: ["membership not found"]
      }, status: 404
    end
  end

  def update
    @membership = Membership.includes(:users).find(params[:membership_id])
    @user = current_user

    if @membership 
      @membership.update(membership_update_params)
  
      render json: @membership        
    else
      render json: {
        status: 'error',
        errors: ["membership not found"]
      }, status: 404
    end  
  end

  def destroy

  end

  private 

    def membership_create_params
      if @user.is_super_user or @membership.is_admin
        params.require(:membership).permit(:user_id, :group_id, :is_admin, :group_email_subscribed, :position)
      else
        params.require(:membership).permit(:user_id, :group_id, :group_email_subscribed)
      end
    end 

    def membership_update_params
      
      if @user.is_super_user or @membership.is_admin
        params.permit(:is_admin, :group_email_subscribed, :position)
      else
        params.permit(:group_email_subscribed)
      end
    end 

end
