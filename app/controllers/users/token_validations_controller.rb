class Users::TokenValidationsController < DeviseTokenAuth::TokenValidationsController


  def validate_token
    # @resource will have been set by set_user_token concern
    if @resource
      yield if block_given?
      render_validate_token_success
    else
      render_validate_token_error
    end
  end

  protected 

  def render_validate_token_success
    render json: {
      success: true,
      data: @resource.token_validation_response
    }
  end

  def render_validate_token_error
    render json: {
      success: false,
      errors: ["Invalid login credentials"]
    }, status: 401
  end

end
