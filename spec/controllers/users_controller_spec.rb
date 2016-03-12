require 'rails_helper'

RSpec.describe UsersController, type: :controller do

    before(:each) do 
      @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
      @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)

      @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
      @informations = {first_name: 'first_test',
                      last_name: 'last_test',
                      country: 'DE',
                      city: 'Berlin',
                      date_of_birth: '3.12.1995',
                      gender: 0,
                      program_type: 0,
                      institution: 'example institutation',
                      year_of_participation: 2006,
                      country_of_participation: 'DE',
                      student_company_name: 'company name'}

    end


    describe 'GET /users' do
        it "should return 401 for accesing users if user has not completed his profile", :broken => true do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do

          get :index, format: :json

          expect(response.code).to eq "401"

        end

        it "should allow users, who completed their profiles, to access their/other profiles" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json


          expect(response).to be_success

          userswithcompletedprofile = json.select {|v| v["completed_profile"] == true }

          expect(json.length).to eq userswithcompletedprofile.length
        end

        it "should not allow normal users, who completed their profiles, to access subscription_id of other users" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response).to be_success

          userswithsubscriptionid = json.select {|v| v.has_key? "subscription_id" }
          userswithispremium = json.select {|v| v.has_key? "is_premium" }

          expect(userswithsubscriptionid.length).to eq 1
          expect(json.length).to eq userswithispremium.length

        end        

        it "should allow super users to access subscription_id of all users" do

          auth_headers = @super_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response).to be_success
          userswithsubscriptionid = json.select {|v| v.has_key? "subscription_id" }

          expect(json.length).to eq userswithsubscriptionid.length
        end



    end

    describe 'GET /users/:id' do
        it "should return 401 for accesing users if user has not completed his profile", :broken => true do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :show, :id => @completed_profile_user.id, format: :json

          expect(response.code).to eq "401"

          get :show, :id => @registered_user.id, format: :json

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do

          get :show, :id => @completed_profile_user.id, format: :json

          expect(response.code).to eq "401"

        end

        it "should allow other users, who completed their profiles, to access their/other profiles" do
          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :show, :id => @completed_profile_user.id, format: :json

          expect(response).to be_success
        end
    end

    describe 'PUT /users' do

        it "should return 401 if user is not registered" do

          put :update, @informations

          expect(response.code).to eq "401"

        end

        it "should return 401 if user completed his profile" , :broken => true do
          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          put :update, @informations

          expect(response.code).to eq "401"

        end

        it "should allow registered user to complete his profile if all informations are valid" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          put :update, @informations

          expect(response).to be_success

        end

        it "should not allow registered user to complete his profile if all informations are not valid", :broken => true do

          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)
          _informations = @informations.clone
          _informations.delete(:country) # does not work
          #_informations[:country] = nil # works
          #_informations[:year_of_participation] = 10 #works
          put :update, _informations

          expect(response.code).to eq "403"

          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)
        

        end     

    end

end
