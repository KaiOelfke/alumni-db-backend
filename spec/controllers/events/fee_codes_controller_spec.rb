require 'rails_helper'

RSpec.describe Events::FeeCodesController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
    @super_user = FactoryGirl.create(:user, :registered, :confirmed_email, :personal_programm_data, :super)
    @event_with_fees = FactoryGirl.create(:event, :with_payment)
    @fee_with_fee_codes = FactoryGirl.create(:fee, :fee_codes)
    @fee_code = FactoryGirl.create(:fee_code)
    @event_without_application_payment = FactoryGirl.create(:event)
    @buggy_fee_code = FactoryGirl.create(:fee_code, :with_payment_and_no_fee)
    @used_code = FactoryGirl.create(:fee_code, :used)
    @fee_code_event_payment = FactoryGirl.create(:fee_code, :with_payment)
    @public_fee = FactoryGirl.create(:fee)
  end





  describe 'GET /fee_codes' do

    it "should return 403 if user without super_user grants want to access all fee_codes" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 200 with all fees if super user want to access all fee_codes" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, format: :json
      expect(response.code).to eq "200"
    end
  end

  describe 'GET /events/:event_id/validate_code' do
    it 'should succeed with just boolean, if event is with_application' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @fee_code.event.id, code: @fee_code.code, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["valid"]).to be_truthy
    end

    it 'should succeed with boolean and fee, if event is with_payment' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @fee_code_event_payment.event.id, code: @fee_code_event_payment.code, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["valid"]).to be_truthy
      expect(json["data"]["fee"]["id"]).to eq @fee_code_event_payment.fee.id
      expect(json["data"]["fee"]["public_fee"]).to be false
    end

    it 'should return 404 with correct error message, if code is used' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @used_code.event.id, code: @used_code.code, format: :json
      expect(response.code).to eq "404"
      expect(json["errors"][0]).to eq "code is already used"
    end

    it 'should return 404 with event, if event not found' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: 1337, code: @fee_code.code, format: :json
      expect(response.code).to eq "404"
      expect(json["errors"][0]).to eq "event not found"
    end

    it 'should return 404 with code, if code not found' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @event_with_fees.id, code: 'abcd13371337', format: :json
      expect(response.code).to eq "404"
      expect(json["errors"][0]).to eq "code not found"
    end

    it 'should return 400, if event is without application payment' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @event_without_application_payment.id, code: @fee_code.code, format: :json
      expect(response.code).to eq "400"
    end

    it 'should return 400, if code param is missing' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @event_with_fees.id, format: :json
      expect(response.code).to eq "400"
    end

    # not working, because url generation fails
    # it 'should return 400, if event_id param is missing' do
    #   auth_headers = @completed_profile_user.create_new_auth_token
    #   request.headers.merge!(auth_headers)
    #   get :validate_code, event_id: nil, code: @fee_code.code, format: :json
    #   expect(response.code).to eq "400"
    # end

    it 'should return 400, if event of code and event id is not matching' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @event_with_fees.id, code: @fee_code.code, format: :json
      expect(response.code).to eq "400"
    end

    it 'should return 500, if special fee is missing for event with payment' do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :validate_code, event_id: @buggy_fee_code.event.id, code: @buggy_fee_code.code, format: :json
      expect(response.code).to eq "500"
    end

  end

  describe 'GET /events/:event_id/fee_codes' do

    it "should return 403 if user without super_user grants want to access all fee_codes for specific event" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :all_codes_for_event, event_id: @fee_with_fee_codes.event.id, format: :json
      expect(response.code).to eq "403"
    end


    # it "should return 200 with all fees if super user want to access all fee_codes for specific event" do
    #   auth_headers = @super_user.create_new_auth_token
    #   request.headers.merge!(auth_headers)
    #   get :all_fees_for_event, event_id: @fee_with_fee_codes.event.id ,format: :json
    #   feeCodes = @fee_with_fee_codes.event.fees.joins(:fee_codes)
    #   #puts json['data']
    #   expect(response.code).to eq "200"
    #   expect(json['data'].length).to eq(3)
    #   json['data'].each_with_index do |fee_code, index|
    #     expect(fee_code['id']).to eq feeCodes[index][:id]
    #   end

    # end
    it "should return 200 with all fee codes if super user want to access all fee_codes for specific event" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :all_codes_for_event, event_id: @fee_with_fee_codes.event.id ,format: :json
      feeCodes = Events::FeeCode.where(event_id: @fee_with_fee_codes.event.id)
      #puts json['data']
      expect(response.code).to eq "200"
      expect(json['data'].length).to eq(3)
      json['data'].each_with_index do |fee_code, index|
        expect(fee_code['id']).to eq feeCodes[index][:id]
      end
    end

    it "should return 400 for events without application and payment" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :all_codes_for_event, event_id: @event_without_application_payment ,format: :json
      expect(response.code).to eq "400"
    end
  end


  describe 'GET /fee_codes/:id' do
    it "should return 403 if user without super_user grants want to access a fee_code" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @fee_code.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if super user want to access a nonexistent fee_code " do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => 99999, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with fee_code if super user want to access a fee_code with fee_code_id" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @fee_code.id, format: :json
      expect(response.code).to eq "200"
    end

    it "should return 200 with fee_code if super user want to access a fee_code with fee_code_code" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, :id => @fee_code.code, format: :json
      expect(response.code).to eq "200"
    end
  end


  describe 'POST /fee_codes' do

    it "should return 403 if user without super user permissions want to create a fee" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee_code)
      attrs[:user_id] = @completed_profile_user.id

      attrs[:fee_id] = @event_with_fees.fees.take.id
      newFeeCode = Hash.new
      newFeeCode[:fee_code] = attrs
      post :create, newFeeCode, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 400 if super user want to a create a code with wrong params" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee_code)
      attrs[:user_id] = @completed_profile_user.id
      attrs[:event_id] = @event_without_application_payment.id
      newFeeCode = Hash.new
      newFeeCode[:fee_code] = attrs
      post :create, newFeeCode, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 400 if super user wants to create a code with for event with payment without fee" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee_code)
      attrs[:user_id] = @completed_profile_user.id
      attrs[:event_id] = @event_with_fees.id
      newFeeCode = Hash.new
      newFeeCode[:fee_code] = attrs
      post :create, newFeeCode, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 400, if super user wants to create a code with a public fee" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee_code)
      attrs[:user_id] = @completed_profile_user.id
      attrs[:event_id] = @event_with_fees.id
      attrs[:fee_id] = @public_fee.id
      newFeeCode = Hash.new
      newFeeCode[:fee_code] = attrs
      post :create, newFeeCode, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 200 with fee_code data if super user want to create a fee code" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:fee_code)
      attrs[:user_id] = @completed_profile_user.id
      attrs[:fee_id] = @fee_code_event_payment.fee.id
      attrs[:event_id] = @fee_code_event_payment.event.id
      newFeeCode = Hash.new
      newFeeCode[:fee_code] = attrs
      post :create, newFeeCode, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["user_id"]).to eq attrs[:user_id]
      expect(json["data"]["fee_id"]).to eq attrs[:fee_id]
      expect(json["data"]["event_id"]).to eq attrs[:event_id]
      expect(json["data"]["code"]).to be_truthy
    end


  end




  # describe 'PUT /fee_codes/:id' do
  #   let(:changedAttrCorrect) do
  #     { :delete_flag => true}
  #   end 

  #   it "should return 403 if user without super user permissions want to update a fee_code" do
  #   	auth_headers = @completed_profile_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, id: @fee_code.id, :fee_code => changedAttrCorrect, format: :json
  #     expect(response.code).to eq "403"
  #   end

  #   it "should return 404 if super user want to update a nonexistent fee_code" do
  #   	auth_headers = @super_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, id: 99999, :fee_code => changedAttrCorrect, format: :json
  #     expect(response.code).to eq "404"
  #   end

  #   it "should return 200 with fee_code data if super user want to update a fee_code" do
  #   	auth_headers = @super_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, id: @fee_code.id, :fee_code => changedAttrCorrect, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @fee_code.id      
  #     expect(json["data"]["delete_flag"]).to eq true
  #   end

  # end

  describe 'DESTROY /fee_codes/:id' do

    it "should return 403 if user without super user permissions want to delete a fee_code" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, id: @fee_code.id, format: :json
      expect(response.code).to eq "403"    	
    end

    it "should return 404 if super user want to delete a nonexistent fee_code" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, id: 555555, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with fee_code data if super user want to delete a fee_code" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      delete :destroy, id: @fee_code.id, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["delete_flag"]).to eq true      
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
