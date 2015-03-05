class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    include ActionController::StrongParameters
    include DeviseTokenAuth::Concerns::SetUserByToken

    before_action :configure_permitted_parameters, if: :devise_controller?

    respond_to :json

    protected

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
                                                            :student_company_name]
    end
end

