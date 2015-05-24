require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
    before(:each) do 

      @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
      
      @completed_profile_user_with_groups = FactoryGirl.create(:user_with_groups,
                                                               :registered, :completed_profile, :confirmed_email, :personal_programm_data)

      @completed_profile_admin_user_with_groups = FactoryGirl.create(:user_with_groups,
                                                               :registered, :completed_profile, :confirmed_email, :personal_programm_data,
                                                               is_admin: true)                                  

      @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
      @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
      @group = FactoryGirl.create(:group)

    end

#GET /groups/:id/users(.:format) groups#users    Get users of group
#GET /groups(.:format)   groups#index    Get all groups
#POST    /groups(.:format)   groups#create   Create a new group
#GET /groups/:id(.:format)   groups#show Show group settings
#PUT /groups/:id(.:format)   groups#update   Change group settings
#DELETE  /groups/:id(.:format)
    
    #Get all groups
    describe 'GET /groups' do
        it "should return 401 for accesing groups if user has not completed his profile" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do

          get :index, format: :json

          expect(response.code).to eq "401"

        end

        it "should return all groups if user has his profile completed" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :index, format: :json

          expect(response).to be_success

          expect(json.length).to eq 3

        end
    end

    #Create a new group
    describe 'POST /groups' do
        it "should return 403 for creating group if user isn't super user" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)
          attrs = FactoryGirl.attributes_for(:group)
          newGroup = Hash.new
          newGroup[:group] = attrs

          post :create, newGroup

          expect(response.code).to eq "403"

        end

        it "should return 401 if user is not registered" do

          attrs = FactoryGirl.attributes_for(:group)
          newGroup = Hash.new
          newGroup[:group] = attrs

          post :create, newGroup

          expect(response.code).to eq "401"

        end

        it "should create a group if user is super user" do

          auth_headers = @super_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          attrs = FactoryGirl.attributes_for(:group)
          newGroup = Hash.new
          newGroup[:group] = attrs

          post :create, newGroup

          expect(response).to be_success

        end 
    end    

    #Show group settings
    describe 'GET /groups/:id' do
        it "should return 401 for accesing groups settings if user has not completed his profile" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :show, :id => @group.id

          expect(response.code).to eq "401"

        end

        it "should return 401 if user is not registered" do

          get :show, :id => @group.id

          expect(response.code).to eq "401"

        end

        it "should return groups settings if user has his profile completed" do

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          get :show, :id => @group.id

          expect(response).to be_success
        end
    end

    #Change group settings
    describe 'PUT /groups/id' do
        let(:changedAttr) do 
          { :group_email_enabled => true }
        end

        it "should return 403 for updating group if user isn't super user or admin of the group" do
          auth_headers = @completed_profile_user_with_groups.create_new_auth_token
          request.headers.merge!(auth_headers)


          put :update, :id => @group.id, :group => changedAttr

          expect(response.code).to eq "403"

        end


        it "should return 401 if user is not registered" do
          
          put :update, :id => @group.id, :group => changedAttr

          expect(response.code).to eq "401"

        end

        it "should update a group if user is admin of a group" do

          auth_headers = @completed_profile_admin_user_with_groups.create_new_auth_token
          request.headers.merge!(auth_headers)

          memberships = @completed_profile_admin_user_with_groups.memberships
          group = memberships.first.group
          put :update, :id => group.id, :group => changedAttr, format: :json

          expect(response).to be_success
          expect(json['data']['group_email_enabled']).to eq true

        end 

        it "should update a group if user is super user" do

          auth_headers = @super_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          put :update, :id => @group.id, :group => changedAttr

          expect(response).to be_success

        end 
    end
    
    #Destroy group
    describe 'DELETE /groups/id' do
        it "should return 403 for destroing group if user isn't super user" do
          auth_headers = @registered_user.create_new_auth_token
          request.headers.merge!(auth_headers)          
          delete :destroy, {:id => @group.id}

          expect(response.code).to eq "403"

          auth_headers = @completed_profile_user.create_new_auth_token
          request.headers.merge!(auth_headers)          
          
          delete :destroy, {:id => @group.id}

          expect(response.code).to eq "403"          

        end



        it "should return 401 if user is not registered" do

          delete :destroy, :id => @group.id

          expect(response.code).to eq "401"

        end

        it "should create a group if user is super user" do

          auth_headers = @super_user.create_new_auth_token
          request.headers.merge!(auth_headers)

          delete :destroy, :id => @group.id

          expect(response).to be_success

        end
    end    

end
