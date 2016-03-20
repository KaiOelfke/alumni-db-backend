class SearchController < ApplicationController

  before_action :authenticate_user!

  def search

    @current_user = current_user

    if not (is_integer?(params[:page])) or params[:page] == "0"
      render json: {
        status: 'error',
        errors: ['page number is wrong']
      }, status: 400
      return
    end


    if params[:text]
      @users = User.search(params[:text]).paginate(:page => params[:page])

      render :json => @users.map { |user| 
        if (not @current_user) or (@current_user.id != user.id and not @current_user.is_super_user)
          user.as_json(:except => [:subscription_id, :created_at, :updated_at,
          :customer_id,:tsv]) 
        else
          user.as_json(:except => [:created_at, :updated_at,
          :customer_id, :tsv])
        end
      }
    else
      render json: {
        status: 'error',
        errors: ['no search text specified']
      }, status: 400
    end

  end

  private

  def is_integer? string
    true if Integer(string) rescue false
  end


end
