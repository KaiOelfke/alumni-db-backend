require 'rails_helper'

RSpec.describe Subscriptions::DiscountsController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @discount = FactoryGirl.create(:discount)
    @plan = FactoryGirl.create(:plan)

  end



  describe 'GET /subscriptions/discounts' do

    it "should return 404 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow super user to access all discounts" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "200"
    end
  end


  describe 'POST /subscriptions/discounts' do

    it "should return 404 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:discount)
      newDiscount = Hash.new
      newDiscount[:discount] = attrs
      newDiscount[:discount][:plan_id] = @plan.id
      newDiscount[:discount][:code] = "newCode15"

      post :create, newDiscount, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow super user to create a new discount codes" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:discount)
      newDiscount = Hash.new
      newDiscount[:discount] = attrs
      newDiscount[:discount][:plan_id] = @plan.id
      newDiscount[:discount][:code] = "newCode15"

      post :create, newDiscount, format: :json
      expect(response).to be_success
    end
  end



  describe 'GET /subscriptions/discounts/:id' do

    it "should return 404 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @discount.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow super user to access discounts" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @discount.id, format: :json
      expect(response).to be_success
    end
  end


  describe 'PUT /subscriptions/discounts/:id' do
    let(:changedAttr) do
      { :price => 5 }
    end

    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => @discount.id, :discount => changedAttr, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if discount doesn't exist" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => 5, :discount => changedAttr, format: :json
      expect(response.code).to eq "404"
    end

    it "should allow super user update discount" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => @discount.id, :discount => changedAttr, format: :json
      expect(response).to be_success
    end

  end


  describe 'DELETE /subscriptions/discounts/:id' do

    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @discount.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if discount doesn't exist" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => 5, format: :json
      expect(response.code).to eq "404"
    end

    # by setting delete flag to the value true
    it "should allow super user delete discount" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @discount.id,  format: :json
      expect(response).to be_success
      expect(response.body).to include('"delete_flag":true')
    end
  end

  describe 'GET /subscriptions/discounts/check' do
    let(:good_query) do
      { :code => @discount.code ,
        :plan_id => @discount.plan.id
      }
    end

    let(:bad_query) do
      { :code => "555554544" ,
        :plan_id => @discount.plan.id
      }
    end

    it "should return error if the required query params don't exist" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)

      expect{get(:check, {:discount => {}}, format: :json)}.to raise_error ActionController::ParameterMissing
    end

    it "should return error if the discount doesn't exist " do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :check, :discount => good_query, format: :json
      expect(response).to be_success

    end

    it "should return success if the plan the  provided discount " do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :check, :discount => bad_query, format: :json
      expect(response.code).to  eq "404"
    end

  end



end
