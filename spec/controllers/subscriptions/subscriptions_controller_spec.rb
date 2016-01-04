require 'rails_helper'

RSpec.describe Subscriptions::SubscriptionsController, type: :controller do


  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered,
      :completed_profile, :confirmed_email, :personal_programm_data)
    @completed_profile_subscribred_user = FactoryGirl.create(:user, :registered,
      :completed_profile, :confirmed_email, :personal_programm_data, :subscribed)

    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @plan = FactoryGirl.create(:plan)
    @discount = FactoryGirl.create(:discount)
  end

  describe 'GET /subscriptions/:id' do

    it "should return 404 if user not found" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)

      get :show, :id => 5, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 404 if user isn't subscribred" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @completed_profile_user.id, format: :json
      expect(response.code).to eq "404"
    end


    it "should return 200 if user subscribred" do
      auth_headers = @completed_profile_subscribred_user.create_new_auth_token
      request.headers.merge!(auth_headers)

      get :show, :id => @completed_profile_subscribred_user.id, format: :json
      expect(response).to be_success
    end


    it "should allow super user to access all other subscriptions" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @completed_profile_subscribred_user.id, format: :json
      expect(response).to be_success
    end
  end

  describe 'POST /subscriptions' do


    it "should return 404 if user_id is missing" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:plan_id] = @plan.id
      newSubscription[:subscription][:payment_method_nonce] = Braintree::Test::Nonce::Transactable

      post :create, newSubscription, format: :json
      expect(response.code).to eq "404"
    end


    it "should return 404 if discount_id isn't valid" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:discount_id] = 456

      post :create, newSubscription, format: :json
      expect(response.code).to eq "404"
    end


    it "should return 404 if default plan does not exist or plan_id isn't valid" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:plan_id] = 456
      newSubscription[:subscription][:user_id] =  @completed_profile_user.id

      post :create, newSubscription, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 404 if nonce token isn't provided and the user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:plan_id] = @plan.id
      newSubscription[:subscription][:user_id] =  @completed_profile_user.id

      post :create, newSubscription, format: :json
      expect(response.code).to eq "404"

    end

    it "should allow user to be permium user wihtout discount" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:plan_id] = @plan.id
      newSubscription[:subscription][:user_id] =  @completed_profile_user.id
      newSubscription[:subscription][:payment_method_nonce] = Braintree::Test::Nonce::Transactable

      post :create, newSubscription, format: :json
      expect(response).to be_success
    end

    it "should allow user to be permium user with discount" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:plan_id] =  @discount.plan.id
      newSubscription[:subscription][:discount_id] =  @discount.id
      newSubscription[:subscription][:user_id] =  @completed_profile_user.id

      newSubscription[:subscription][:payment_method_nonce] = Braintree::Test::Nonce::TransactableVisa

      post :create, newSubscription, format: :json
      expect(response).to be_success
    end

    it "should allow user to be permium user with default plan" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      @defaultPlan = FactoryGirl.create(:plan, :default)

      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:user_id] =  @completed_profile_user.id
      newSubscription[:subscription][:payment_method_nonce] = Braintree::Test::Nonce::TransactableMasterCard

      post :create, newSubscription, format: :json
      expect(response).to be_success
    end

    it "should allow super user to create premium memberships" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:subscription)
      newSubscription = Hash.new
      newSubscription[:subscription] = attrs
      newSubscription[:subscription][:plan_id] =  @plan.id
      newSubscription[:subscription][:user_id] =  @completed_profile_user.id

      post :create, newSubscription, format: :json
      expect(response).to be_success
    end
  end


  describe 'DELETE /subscriptions' do

    it "should return 403 if user tried to unsubscribe anther user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @completed_profile_subscribred_user.subscription_id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if user isn't subscribred" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @completed_profile_user.subscription_id, format: :json
      expect(response.code).to eq "404"
    end

    it "should allow user to unsubscribe if he is subscribred" do
      auth_headers = @completed_profile_subscribred_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @completed_profile_subscribred_user.subscription_id,  format: :json
      expect(response).to be_success
      expect(@completed_profile_subscribred_user.reload.subscription_id).to eq nil
    end

    it "should allow super user unsubscribe users" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @completed_profile_subscribred_user.subscription_id,  format: :json
      expect(response).to be_success
      expect(@completed_profile_subscribred_user.reload.subscription_id).to eq nil
    end
  end




end
