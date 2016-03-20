require 'rails_helper'

RSpec.describe SearchController, type: :controller do

    before(:each) do 
      @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
    end

    describe 'GET /search' do

      it "should return 400 for accesing users if user has not completed his profile" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)

        get :search, format: :json

        expect(response.code).to eq "400"

      end

      it "should return 400 for accesing users if user has not completed his profile" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)

        get :search, {page: "test", :text => "kai Bio"}, format: :json

        expect(response.code).to eq "400"

      end

      it "should return 400 for accesing users if user has not completed his profile" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)

        get :search, {page: "0", :text => "kai Bio"}, format: :json

        expect(response.code).to eq "400"

      end

      it "should return 200 for accesing users if user has not completed his profile" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)

        get :search, {page: "1", :text => "kai"}, format: :json

        expect(response.code).to eq "200"
        expect(json.length).to be > 0

      end

    end
end