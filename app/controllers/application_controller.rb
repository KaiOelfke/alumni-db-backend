class ApplicationController < ActionController::API
    include ActionController::StrongParameters
    include DeviseTokenAuth::Concerns::SetUserByToken
    include HttpExcptions

    before_action :configure_permitted_parameters, if: :devise_controller?
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    respond_to :json


    protected 

      # HTTP-CODE 200
      def success_response(data)
        render json: {
              status: 'success',
              data: data
        }, status: :ok
      end

    private 

      def configure_permitted_parameters
          devise_parameter_sanitizer.for(:account_update) << [:first_name,
                                                              :last_name,
                                                              :country,
                                                              :city,
                                                              :date_of_birth,
                                                              :gender,
                                                              :program_type,
                                                              :institution,
                                                              :year_of_participation,
                                                              :country_of_participation,
                                                              :student_company_name,
                                                              :avatar, #avatar
                                                              :university_name,
                                                              :university_major,
                                                              :founded_company_name,
                                                              :current_company_name,
                                                              :current_job_name,
                                                              :current_job_position,
                                                              :interests,
                                                              :short_bio,
                                                              :alumni_position,
                                                              :member_since,
                                                              :facebook_url,
                                                              :skype_id,
                                                              :twitter_url,
                                                              :linkedin_url,
                                                              :mobile_phone]
      end


      def not_found
        render nothing: true, status: :not_found
      end

      # HTTP-CODE 400
      def bad_request_response(excption)
        render json: {
          status: 'error',
          errors: excption.errors
        }, status: :bad_request
      end

      # HTTP-CODE 403
      def forbidden_response(excption)
        render json: {
          status: 'error',
          errors: excption.errors
        }, status: :forbidden
      end

      # HTTP-CODE 401
      def not_authourized_response(excption)
        render json: {
          status: 'error',
          errors: excption.errors
        }, status: :unauthorized
      end      

      # HTTP-CODE 404
      def not_found_response(excption)

        render json: {
              status: 'error',
              errors: excption.errors
        }, status: :not_found
      end

      # HTTP-CODE 500
      def internal_error_response(excption)
        render json: {
              status: 'error',
              errors: excption.errors
        }, status: :internal_server_error
      end

end
