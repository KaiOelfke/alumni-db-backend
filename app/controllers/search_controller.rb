class SearchController < ApplicationController

  # before_action :authenticate_user!

  def search
    if params[:text]
      render json: User.search(params[:text])
    else
      render json: {
        status: 'error',
        errors: ['no search text specified']
      }, status: 400
    end
  end

end
