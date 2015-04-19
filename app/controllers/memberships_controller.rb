class MembershipsController < ApplicationController

  before_action :authenticate_user!

  # Join a group
  def create
    puts params

    unless params[:membership] and params[:membership][:group_id] and
      params[:membership][:user_id]
      return render json: {
        status: 'error',
        errors: ["Missing param."]
      }, status: 403
    end

    @user = current_user
    @membership = @user.memberships.find_by(group_id: params[:membership][:group_id])
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
    @membership = Membership.find(params[:id])
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
    @membership = Membership.find(params[:id])
    @user = current_user

    if @membership
      if @user.is_super_user or @membership.is_admin

        #Admins and super users can update memberships for every user
        if @membership.update(membership_update_params)
          render json: {
            status: 'success',
            data:   @membership.as_json()
          }
        else
          render json: {
            status: 'error',
            errors: @membership.errors
          }, status: 403
        end
      else
        #Normal user can only update own memberships
        if (@user.id == @membership.user_id) and @membership.update(membership_update_params)
          render json: {
            status: 'success',
            data:   @membership.as_json()
          }
        else
          render json: {
            status: 'error',
            errors: @membership.errors
          }, status: 403
        end
      end

    else
      render json: {
        status: 'error',
        errors: ["membership not found"]
      }, status: 404
    end

  end

  def destroy
    @membership = Membership.find(params[:id])
    @user = current_user
    if @membership
      if @user.is_super_user or @membership.is_admin
        #Admins and super users can delete memberships for every user
        if @membership.destroy
          render json: {
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @membership.errors
          }, status: 403
        end
      else
        #Normal users can only delete their own memberships
        if (@user.id == @membership.user_id) and @membership.destroy
          render json: {
            status: 'success'
          }
        else
          render json: {
            status: 'error',
            errors: @membership.errors
          }, status: 403
        end
      end
    else
      render json: {
        status: 'error',
        errors: ["membership not found"]
      }, status: 404
    end
  end

  private

    def membership_create_params
      if @user.is_super_user or (@membership and @membership.is_admin)
        params.require(:membership).permit(:user_id, :group_id, :is_admin, :group_email_subscribed, :position)
      else
        params.require(:membership).permit(:user_id, :group_id, :group_email_subscribed)
      end
    end

    def membership_update_params

      if @user.is_super_user or (@membership and @membership.is_admin)
        params.require(:membership).permit(:is_admin, :group_email_subscribed, :position)
      else
        params.require(:membership).permit(:group_email_subscribed)
      end
    end

end
