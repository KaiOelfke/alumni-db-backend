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
end

