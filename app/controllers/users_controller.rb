class UsersController < ApplicationController

  before_action :authenticate_user!

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    render json: @user
  end

  private

    def user_params
      params.require(:user).permit(:username, :email)
    end
end
