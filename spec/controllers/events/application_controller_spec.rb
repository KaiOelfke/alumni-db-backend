require 'rails_helper'

RSpec.describe Events::ApplicationController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @published_event = FactoryGirl.create(:event, :published)
    @eventWithPayment = FactoryGirl.create(:event, :with_payment)
    @eventWithApplication = FactoryGirl.create(:event, :with_application)
    @application = FactoryGirl.create(:application)
  end

  describe 'GET /events/:event_id/applications' do

    it "should return 403 if user is not super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: @application.event.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow super user to access all applications" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: @application.event.id, format: :json
      expect(response.code).to eq "200"
      expect(json["data"].length).to eq 1
    end
  end


  describe 'POST /events' do

    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:event)
      newEvent = Hash.new
      newEvent[:event] = attrs
      post :create, newEvent, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 500 if event params are wrong" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:event)
      attrs.delete(:etype)
      newEvent = Hash.new
      newEvent[:event] = attrs
      post :create, newEvent, format: :json
      expect(response.code).to eq "500"
    end


    it "should allow super user to create a new event" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:event)
      newEvent = Hash.new
      newEvent[:event] = attrs
      post :create, newEvent, format: :json
      expect(response).to be_success
    end
  end

end
