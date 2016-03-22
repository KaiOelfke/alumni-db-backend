require 'rails_helper'

RSpec.describe Subscriptions::EventsController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @registered_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @published_event = FactoryGirl.create(:event, :published)
    @event = FactoryGirl.create(:event)
  end



  describe 'GET /events' do

    it "should return all published events if user is not super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "200"
      
      publishedEvents = json.select {|v| v["published"] == true }
      notPublishedEvents = json.select {|v| v["published"] == false }
      expect(json.length).to eq publishedEvents.length
      expect(notPublishedEvents.length).to eq 0
    end

    it "should allow super user to access all events" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "200"

      publishedEvents = json.select {|v| v["published"] == true }
      notPublishedEvents = json.select {|v| v["published"] == false }
      expect(publishedEvents.length).to eq 1
      expect(notPublishedEvents.length).to eq 1
      expect(json.length).to eq (publishedEvents.length + notPublishedEvents.length)
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



  describe 'GET /events/:id' do

    it "should return 404 if event doesn't exist" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => 1337, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 403 if user isn't super user and event is not published" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @event.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should allow user to access published event" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @published_event.id, format: :json
      expect(response.code).to eq "200"
    end

    it "should allow super user to access not published events" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @event.id, format: :json
      expect(response).to be_success
    end

    it "should allow super user to access published events" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @published_event.id, format: :json
      expect(response).to be_success
    end
  end


  describe 'PUT /events/:id' do

    let (:updatedEvent) do 
      {name: 'Updated Conference',
        description: 'Awesome conference',
        location: 'Copenhagen',
        dates: '11.11.16 - 13.13.16',
        agenda: 'Agenda TBC',
        contact_email: 'nobody@alumnieurope.org',
        published: false}
      end


    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => @event.id, :event => updatedEvent, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if event doesn't exist" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => 1337, :event => updatedEvent, format: :json
      expect(response.code).to eq "404"
    end

    it "should allow super user update event" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, :id => @event.id, :event => updatedEvent, format: :json
      expect(response).to be_success
      expect(@event.reload.name).to eq 'Updated Conference'
    end

  end


  describe 'DELETE /events/:id' do

    it "should return 403 if user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @event.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if event doesn't exist" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => 1337, format: :json
      expect(response.code).to eq "404"
    end

    # by setting delete flag to the value true
    it "should allow super user delete event" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, :id => @event.id,  format: :json
      expect(response).to be_success
      expect(@event.reload.delete_flag).to eq true
    end
  end


end
