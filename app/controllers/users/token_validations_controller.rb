class Users::TokenValidationsController < DeviseTokenAuth::TokenValidationsController

  def validate_token

    if @resource
      render json: {
        data: @resource.as_json()
      }
    else
      render json: {
        success: false,
        errors: ["Invalid login credentials"]
      }, status: 401
    end
  end
end
