require 'rails_helper'

RSpec.describe UsersController, type: :controller do

    before(:each) do 
      @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
      @completed_profile_user_with_groups = FactoryGirl.create(:user_with_groups,
                                                               :registered,
                                                               :completed_profile,
                                                               :confirmed_email,
                                                               :personal_programm_data,
                                                               is_admin: true)
      
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

    describe 'GET /users/:user_id/memberships' do
        it "should return 401 for accesing user memberships if user has not completed his profile" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :memberships, user_id: @registered_user.id, format: :json

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do

          get :memberships, user_id: @registered_user.id, format: :json

          expect(response.code).to eq "401"

        end

        it "should allow user, who completed their profiles, to access their/other memberships" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :memberships, user_id: @completed_profile_user_with_groups.id, format: :json

          expect(response).to be_success

          expect(json['data'].length).to eq 1

        end
    end


    describe 'GET /users' do
        it "should return 401 for accesing users if user has not completed his profile" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do

          get :index, format: :json

          expect(response.code).to eq "401"

        end

        it "should allow other users, who completed their profiles, to access their/other profiles" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response).to be_success



          expect(json.length).to eq 3

        end
    end

    describe 'GET /users/:id' do
        it "should return 401 for accesing users if user has not completed his profile" do
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


        it "should return 401 if user completed his profile" do
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

        it "should not allow registered user to complete his profile if all informations are not valid" do

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
