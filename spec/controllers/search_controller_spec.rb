require 'rails_helper'

RSpec.describe SearchController, type: :controller do

    before(:each) do 
      @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
      @registered_user_two = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data_diff)

    end

    describe 'GET /search' do

      it "should return 400 if the user doesn't provide text param" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)
        get :search, format: :json
        expect(response.code).to eq "400"
      end

      it "should return 400 if the page param isn't number" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)
        get :search, {page: "test", :text => "kai Bio"}, format: :json
        expect(response.code).to eq "400"
      end

      it "should return 400 if the page param is 0" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)
        get :search, {page: "0", :text => "kai Bio"}, format: :json
        expect(response.code).to eq "400"
      end

      it "should return 200 if the page param is null and text exists" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)
        get :search, {:text => "kai Bio"}, format: :json
        expect(response.code).to eq "200"
      end

      it "should return 200 and users who's first name is first_test" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)
        get :search, {page: "1", :text => "first_test"}, format: :json
        expect(response.code).to eq "200"
        expect(json["data"]["total_count"]).to eq 2
      end

      it "should return 200 and users who's first name is first_test and live in berlin" do
        auth_headers = @registered_user.create_new_auth_token
        request.headers.merge!(auth_headers)
        get :search, {page: "1", :text => "first_test berlin"}, format: :json
        expect(response.code).to eq "200"
        expect(json["data"]["total_count"]).to eq 1
      end

    end
end