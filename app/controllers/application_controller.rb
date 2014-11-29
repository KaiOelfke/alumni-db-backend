class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    include ActionController::StrongParameters
    include DeviseTokenAuth::Concerns::SetUserByToken

    respond_to :json
end
