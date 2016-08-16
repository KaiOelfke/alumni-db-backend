require 'rails_helper'

RSpec.describe Events::ApplicationsController, type: :controller do

  before(:each) do
    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @not_published_event = FactoryGirl.create(:event, etype: :with_application)
    @eventWithPayment = FactoryGirl.create(:event, :with_payment)
    @eventWithApplication = FactoryGirl.create(:event, :with_application)
    @application = FactoryGirl.create(:application, user: @completed_profile_user)
  end

  describe 'GET /events/:event_id/applications' do

    it "should return 400 if event is without application" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: @eventWithPayment.id, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 404 if event is not found" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: 1337, format: :json
      expect(response.code).to eq "404"
    end

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


  describe 'POST /events/:event_id/applications' do

    it "should return 400 if event is without application" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:application)
      newApplication = Hash.new
      newApplication[:application] = attrs
      newApplication[:event_id] = @eventWithPayment.id
      post :create, newApplication, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 400 if user already applied" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:application)
      attrs["motivation"] = @application.motivation
      newApplication = Hash.new
      newApplication[:application] = attrs
      newApplication[:event_id] = @application.event.id
      post :create, newApplication, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 404 if event is not found" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:application)
      newApplication = Hash.new
      newApplication[:application] = attrs
      newApplication[:event_id] = 1337
      post :create, newApplication, format: :json
      expect(response.code).to eq "404"
    end

    it "should allow user to create a new application" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:application)
      newApplication = Hash.new
      newApplication[:application] = attrs
      newApplication[:event_id] = @eventWithApplication.id
      post :create, newApplication, format: :json
      expect(response.code).to eq "200"
    end

    it "should return 400 if user wants to create a new application for not published event" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:application)
      newApplication = Hash.new
      newApplication[:application] = attrs
      newApplication[:event_id] = @not_published_event.id
      post :create, newApplication, format: :json
      expect(response.code).to eq "400"
    end
  end

end
