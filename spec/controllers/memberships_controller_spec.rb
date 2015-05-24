require 'rails_helper'

RSpec.describe MembershipsController, type: :controller do

    before(:each) do 
      @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
      @completed_profile_admin_user_with_groups = FactoryGirl.create(:user_with_groups,
                                                               :registered, :completed_profile, :confirmed_email, :personal_programm_data, is_admin: true)
      @completed_profile_user_with_groups = FactoryGirl.create(:user_with_groups,
                                                               :registered, :completed_profile, :confirmed_email, :personal_programm_data, is_admin: false)
      
      @group_with_two_users = FactoryGirl.create(:group_with_user)

      @group = FactoryGirl.create(:group)
      @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
      @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)

    end

#GET /memberships/:membership_id membership.#show    Settings for membership (one group / user)
#PUT /memberships/:membership_id membership.#update  Change settings of membership
#POST    /memberships    membership.#create  New membership
#DELETE  /memberships/:membership_id membership.#destroy Cancel membership


    describe 'GET /memberships/:membership_id' do

        it "should return 401 for accesing memberschip settings if user has not completed his profile" do
          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)
          membership = @completed_profile_user_with_groups.memberships.first
          get :show, id: membership.id, format: :json

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do
          membership = @completed_profile_user_with_groups.memberships.first

          get :show, id: membership.id, format: :json

          expect(response.code).to eq "401"

        end

        it "should allow user, who completed their profiles, to access membership settings" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          membership = @completed_profile_user_with_groups.memberships.first

          get :show, id: membership.id, format: :json

          expect(response).to be_success
        end
    end

    describe 'PUT /memberships/:membership_id' do
        let(:changedAttr) do 
          { :group_email_subscribed => true }
        end

        it "should allow user to change their membership settings " do
          auth_headers = @completed_profile_user_with_groups.create_new_auth_token
          request.headers.merge!(auth_headers)

          membership = @completed_profile_user_with_groups.memberships.first

          put :update, id: membership.id, :membership => changedAttr 

          expect(response.code).to eq "200"

        end

        it "should allow super user to change membership settings" do
          auth_headers = @super_user.create_new_auth_token
          request.headers.merge!(auth_headers)
          
          membership = @completed_profile_user_with_groups.memberships.first

          put :update, id: membership.id, :membership => changedAttr 
          expect(response.code).to eq "200"


        end

        it "should allow admin of a group to edit memberships of the same group" do
          admin = @group_with_two_users.memberships.first.user
          userMembership = @group_with_two_users.memberships.last

          auth_headers = admin.create_new_auth_token
          request.headers.merge!(auth_headers)
          
          put :update, id: userMembership.id, :membership => changedAttr 
          expect(response.code).to eq "200"


        end

        it "should return 403 if user does not own membership" do
          auth_headers = @completed_profile_user_with_groups.create_new_auth_token
          request.headers.merge!(auth_headers)
          
          membership = @completed_profile_admin_user_with_groups.memberships.first

          put :update, id: membership.id, :membership => changedAttr 
          expect(response.code).to eq "403"


        end        

        it "should return 401 if user is not registered" do
          membership = @completed_profile_admin_user_with_groups.memberships.first

          put :update, id: membership.id, :membership => changedAttr 

          expect(response.code).to eq "401"

        end

    end

    describe 'POST /memberships' do
        let(:changedAttr) do 
          { :group_id => @group.id }
        end

        it "should return 401 for creating memberships if user has not completed his profile" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          membership = { :user_id => @registered_user.id, :group_id => @group.id }

          post :create, :membership => membership

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do
          membership = { :user_id => @registered_user.id, :group_id => @group.id }

          post :create, :membership => membership

          expect(response.code).to eq "401"

        end

        it "should allow user, who completed their profiles, to create memberships" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)
          membership = { :user_id => @registered_user.id, :group_id => @group.id }

          post :create, :membership => membership

          expect(response).to be_success


        end
    end

    describe 'DELETE /memberships/:membership_id' do

        it "should allow user to destroy their membership " do
          auth_headers = @completed_profile_user_with_groups.create_new_auth_token
          request.headers.merge!(auth_headers)

          membership = @completed_profile_user_with_groups.memberships.first

          delete :destroy, id: membership.id 

          expect(response.code).to eq "200"

        end

        it "should allow super user to destroy membership" do
          auth_headers = @super_user.create_new_auth_token
          request.headers.merge!(auth_headers)
          
          membership = @completed_profile_user_with_groups.memberships.first

          delete :destroy, id: membership.id 
          expect(response.code).to eq "200"


        end

        it "should allow admin of a group to destroy memberships of the same group" do
          admin = @group_with_two_users.memberships.first.user
          userMembership = @group_with_two_users.memberships.last

          auth_headers = admin.create_new_auth_token
          request.headers.merge!(auth_headers)
          
          #membership = @completed_profile_user_with_groups.memberships.first
          expect(@group_with_two_users.memberships.first.is_admin).to eq true
          delete :destroy,  id: userMembership.id 
          expect(response.code).to eq "200"


        end

        it "should return 403 if user does not own membership" do
          auth_headers = @completed_profile_user_with_groups.create_new_auth_token
          request.headers.merge!(auth_headers)
          
          membership = @completed_profile_admin_user_with_groups.memberships.first
          delete :destroy, id: membership.id 
          expect(response.code).to eq "403"


        end        

        it "should return 401 if user is not registered" do
          membership = @completed_profile_admin_user_with_groups.memberships.first

          delete :destroy, id: membership.id 

          expect(response.code).to eq "401"

        end

    end

end
