require 'rails_helper'

RSpec.describe Subscriptions::PlansController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @plan = FactoryGirl.create(:plan)
    @default_plan = FactoryGirl.create(:plan, :default)

  end



  describe 'GET /subscriptions/plans' do

    it "should return default plan if user is not super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "200"
      jsonbody = JSON.parse(response.body)
      expect(jsonbody[0]['default']).to eq true
    end

    it "should allow super user to access all discounts" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "200"
    end
  end


  describe 'POST /subscriptions/plans' do

    it "should return 404 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:plan)
      newPlan = Hash.new
      newPlan[:plan] = attrs
      post :create, newPlan, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow super user to create a new plan" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:plan)
      newPlan = Hash.new
      newPlan[:plan] = attrs

      post :create, newPlan, format: :json
      expect(response).to be_success
    end
  end



  describe 'GET /subscriptions/plans/:id' do

    it "should return 404 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @plan.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow super user to access plans" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @plan.id, format: :json
      expect(response).to be_success
    end
  end


  describe 'PUT /subscriptions/plans/:id' do
    let(:changedAttr) do
      { :default => true}
    end

    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => @plan.id, :plan => changedAttr, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if plan doesn't exist" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => 45, :plan => changedAttr, format: :json
      expect(response.code).to eq "404"
    end

    it "should allow super user update plan" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => @plan.id, :plan => changedAttr, format: :json
      expect(response).to be_success
      expect(@default_plan.reload.default).to eq false
      expect(@plan.reload.default).to eq true


    end

  end


  describe 'DELETE /subscriptions/plans/:id' do

    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @plan.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if discount doesn't exist" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => 45, format: :json
      expect(response.code).to eq "404"
    end

    # by setting delete flag to the value true
    it "should allow super user delete discount" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @plan.id,  format: :json
      expect(response).to be_success
      expect(@plan.reload.delete_flag).to eq true
    end
  end


end
