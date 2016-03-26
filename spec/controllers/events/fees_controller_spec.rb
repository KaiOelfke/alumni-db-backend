require 'rails_helper'

RSpec.describe Events::FeesController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @event_with_fees = FactoryGirl.create(:event, :with_fees)
    @fee = FactoryGirl.create(:fee)

  end




  describe 'GET /events/fees' do

    it "should return 400 if event_id isn't specified" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 403 if user without super_user grants want to access all fees" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: 555, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if super user asked to get all fees for a nonexistent event" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: 555, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with all fees if super user want to access all fees" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: @event_with_fees.id ,format: :json
      expect(response.code).to eq "200"
    end


  end


  describe 'POST /events/fees' do

    it "should return 403 if user without super user permissions want to create a fee" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee)
      attrs[:event_id] = @event_with_fees.id
      newFee = Hash.new
      newFee[:fee] = attrs
      post :create, newFee, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 500 if super user want to a create a fee with wrong params" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee)
      newFee = Hash.new
      newFee[:fee] = attrs
      post :create, newFee, format: :json
      expect(response.code).to eq "500"
    end


    it "should return 200 with fee data if super user want to create a fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee)
      attrs[:event_id] = @event_with_fees.id
      newFee = Hash.new
      newFee[:fee] = attrs
      post :create, newFee, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["name"]).to eq attrs[:name]
      expect(json["data"]["price"]).to eq attrs[:price]
      expect(json["data"]["deadline"]).to eq attrs[:deadline]
    end


  end

  describe 'GET /events/fees/:id' do

    it "should return 403 if user without super user permissions want to access a fee" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, id: @fee.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if super user want to access a nonexistent fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, id: 555, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with fee data if super user want to access a fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, id: @fee.id, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["id"]).to eq @fee.id      
      expect(json["data"]["name"]).to eq @fee.name
      expect(json["data"]["price"]).to eq @fee.price
    end

  end


  describe 'PUT /events/fees/:id' do
    let(:changedAttrCorrect) do
      { :price => 5}
    end

    let(:changedAttrBad) do
      { :price => true}
    end    

    it "should return 403 if user without super user permissions want to update a fee" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, id: @fee.id, :fee => changedAttrCorrect, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if super user want to update a nonexistent fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, id: 99999, :fee => changedAttrCorrect, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 500 if super user want to update a fee with bad params" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, id: @fee.id, :fee => changedAttrBad, format: :json
      expect(response.code).to eq "500"
    end

    it "should return 200 with fee data if super user want to update a fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      put :update, id: @fee.id, :fee => changedAttrCorrect, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["id"]).to eq @fee.id      
      expect(json["data"]["name"]).to eq @fee.name
      expect(json["data"]["price"]).to eq 5      
    end

  end

  describe 'destroy /events/fees/:id' do

    it "should return 403 if user without super user permissions want to delete a fee" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, id: @fee.id, format: :json
      expect(response.code).to eq "403"    	
    end

    it "should return 404 if super user want to delete a nonexistent fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, id: 555555, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with fee data if super user want to delete a fee" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, id: @fee.id, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["id"]).to eq @fee.id      
      expect(json["data"]["name"]).to eq @fee.name
      expect(json["data"]["price"]).to eq @fee.price      
    end
  end
end

=begin
	
	


  describe 'POST /events/fees' do

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



  describe 'GET /events/fees/:id' do

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


  describe 'PUT /events/fees/:id' do

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


  describe 'DELETE /events/fees/:id' do

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

=end
