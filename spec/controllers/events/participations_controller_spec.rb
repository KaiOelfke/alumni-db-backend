require 'rails_helper'

RSpec.describe Events::ParticipationsController, type: :controller do

  before(:each) do

    @completed_profile_user = FactoryGirl.create(:user,
                                :registered,
                                :completed_profile,
                                :confirmed_email,
                                :personal_programm_data)
    @super_user = FactoryGirl.create(:user,
                                :registered,
                                :confirmed_email,
                                :personal_programm_data,
                                :super)
    @event_with_fees = FactoryGirl.create(:event, :with_payment)
    @event_with_application = FactoryGirl.create(:event, :with_application)
    @fee = FactoryGirl.create(:fee)
    @participation = FactoryGirl.create(:participation, :without_application_payment, :form)
    @participation_with_application = FactoryGirl.create(:participation, :with_application, :form)
    @participation_with_payment = FactoryGirl.create(:participation, :with_payment, :form)

  end

  describe 'GET /events/:event_id/participations' do

    it "should return 403 if user without super_user grants want to access all participations" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: @participation.event.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if super user asked to get all participations for a nonexistent event" do
    	auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: 555, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with all participations if super user want to access all participations" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :index, event_id: @participation.event.id ,format: :json
      expect(response.code).to eq "200"
    end

  end


  describe 'GET /events/:event_id/participations/:id' do

    it "should return 403 if user doesn't own the participation and the user isn't super user" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, event_id: @participation.event.id, id: @participation.id, format: :json
      expect(response.code).to eq "403"
    end

    it "should return 404 if user want to access a nonexistent participation" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, event_id: @participation.event.id, id: 555, format: :json
      expect(response.code).to eq "404"
    end

    it "should return 200 with participation data if user with the right permissions want to access a participation" do
      auth_headers = @super_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      get :show, event_id: @participation.event.id, id: @participation.id, format: :json
      expect(response.code).to eq "200"
      expect(json["data"]["id"]).to eq @participation.id            
      expect(json["data"]["allergies"]).to eq @participation.allergies
      expect(json["data"]["extra_nights"]).to eq @participation.extra_nights
    end

  end



  # describe 'PUT /events/:event_id/participations/:id' do
  #   let(:changedAttr) do
  #     { :extra_nights => "one extra night"}
  #   end

  #   let(:changeStatus) do
  #     { :status => "approved"}
  #   end

  #   it "should return 404 if super user want to update a nonexistent participation" do
  #     auth_headers = @super_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation.event.id, id: 99999, :participation => changedAttr, format: :json
  #     expect(response.code).to eq "404"
  #   end

  #   it "should return 403 if user without super user permissions and the user doen't own the participation want to update a participation" do
  #     auth_headers = @completed_profile_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation.event.id, id: @participation.id, :participation => changedAttr, format: :json
  #     expect(response.code).to eq "403"
  #   end

  #   it "should return 403 if user want to update a not new participation" do
  #     auth_headers = @participation_paid.user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation_paid.event.id, id: @participation_paid.id, :participation => changedAttr, format: :json
  #     expect(response.code).to eq "403"
  #   end

  #   it "should return 200 with participation data if super user want to update a participation" do
  #     auth_headers = @super_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation.event.id, id: @participation.id, :participation => changedAttr, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @participation.id      
  #     expect(json["data"]["extra_nights"]).to eq changedAttr[:extra_nights]
  
  #   end

  #   it "should return 200 with participation data if super user want to change the status" do
  #     auth_headers = @super_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation.event.id, id: @participation.id, :participation => changeStatus, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @participation.id      
  #     expect(json["data"]["status"]).to eq changeStatus[:status]
  
  #   end

  #   it "should return 200 with participation data if  user want to update his own participation" do
  #     auth_headers = @participation.user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation.event.id, id: @participation.id, :participation => changedAttr, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @participation.id      
  #     expect(json["data"]["extra_nights"]).to eq changedAttr[:extra_nights]
  #   end

  #   it "should return 200 with participation data if user want to change the status, but the status stays without changes" do
  #     auth_headers = @participation.user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     put :update, event_id: @participation.event.id, id: @participation.id, :participation => changeStatus, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @participation.id      
  #     expect(json["data"]["status"]).to eq @participation.status
  #   end


  # end  


  describe 'POST /events/:event_id/participations' do

    # 
    # tests participation without application
    #

    it "should return 400 if the fee_id doesn't exist" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:participation, :form)

      attrs[:event_id] = @event_with_fees.id
      attrs[:user_id] = @completed_profile_user.id      
      attrs[:payment_method_nonce] = Braintree::Test::Nonce::Transactable

      newParticipation = Hash.new
      newParticipation[:participation] = attrs
      newParticipation[:event_id] = @event_with_fees.id

      post :create, newParticipation, format: :json
      expect(response.code).to eq "400"
    end

    it "should return 400 if the code is missing for not public fee" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:participation, :form)
      attrs[:event_id] = @event_with_fees.id
      attrs[:user_id] = @completed_profile_user.id
      attrs[:fee_id] = @event_with_fees.fees.where(:public_fee => false).take.id
      attrs[:payment_method_nonce] = Braintree::Test::Nonce::Transactable
      newParticipation = Hash.new
      newParticipation[:participation] = attrs
      newParticipation[:event_id] = @event_with_fees.id
      post :create, newParticipation, format: :json      
      expect(response.code).to eq "400"
      expect(json["errors"][0]).to eq "code is required for this event"
    end

    it "should return 400 if the code is missing for event with application" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:participation, :form)

      attrs[:event_id] = @event_with_application.id
      attrs[:user_id] = @completed_profile_user.id      
      attrs[:payment_method_nonce] = Braintree::Test::Nonce::Transactable
      newParticipation = Hash.new
      newParticipation[:participation] = attrs
      newParticipation[:event_id] = @event_with_application.id
      post :create, newParticipation, format: :json      
      expect(response.code).to eq "400"
      expect(json["errors"][0]).to eq "code is required for this event"
    end

    it "should return 500 if the payment method is not valid" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:participation, :form)
      attrs[:event_id] = @event_with_fees.id
      attrs[:user_id] = @completed_profile_user.id      
      attrs[:fee_id] = @event_with_fees.fees.where(:public_fee => true).take.id
      attrs[:payment_method_nonce] = Braintree::Test::Nonce::ProcessorDeclinedMasterCard
      newParticipation = Hash.new
      newParticipation[:participation] = attrs
      newParticipation[:event_id] = @event_with_fees.id
      post :create, newParticipation, format: :json
      expect(response.code).to eq "500"
      expect(json["errors"][0]["status"]).to eq "processor_declined"
      expect(json["errors"][0]["code"]).to eq "2000"
      expect(json["errors"][0]["message"]).to eq "Do Not Honor"
    end

    it "should return 500 if the payment method is not valid" do
    	auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:participation, :form)
      attrs[:event_id] = @event_with_fees.id
      attrs[:user_id] = @completed_profile_user.id      
      attrs[:fee_id] =  @event_with_fees.fees.where(:public_fee => true).take.id
      attrs[:payment_method_nonce] = Braintree::Test::Nonce::ProcessorFailureJCB
      newParticipation = Hash.new
      newParticipation[:participation] = attrs
      newParticipation[:event_id] = @event_with_fees.id
      post :create, newParticipation, format: :json
      expect(response.code).to eq "500"
      expect(json["errors"][0]["attribute"]).to eq "number"
      expect(json["errors"][0]["code"]).to eq "81703"
      expect(json["errors"][0]["message"]).to eq "Credit card type is not accepted by this merchant account."
    end

    it "should return 200 if the payment method is valid" do
      auth_headers = @completed_profile_user.create_new_auth_token
      request.headers.merge!(auth_headers)
      attrs = FactoryGirl.attributes_for(:participation, :form)

      attrs[:event_id] = @event_with_fees.id
      attrs[:user_id] = @completed_profile_user.id      
      attrs[:fee_id] = @event_with_fees.fees.where(:public_fee => true).take.id
      attrs[:payment_method_nonce] = Braintree::Test::Nonce::Transactable

      newParticipation = Hash.new
      newParticipation[:participation] = attrs
      newParticipation[:event_id] = @event_with_fees.id

      post :create, newParticipation, format: :json

      expect(response.code).to eq "200"
      expect(json['data']['user_id']).to eq @completed_profile_user.id
      expect(json['data']['fee_id']).to eq attrs[:fee_id]
      expect(json['data']['event_id']).to eq attrs[:event_id]

    end
  end

  # describe 'destroy /events/:event_id/participations/:id' do

  #   it "should return 404 if super user want to delete a nonexistent participation" do
  #     auth_headers = @completed_profile_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     delete :destroy, event_id: @participation.event.id, id: 555555, format: :json
  #     expect(response.code).to eq "404"
  #   end

  #   it "should return 403 if user want to update not his own participation and the user is not super user" do
  #     auth_headers = @completed_profile_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     delete :destroy, event_id: @participation.event.id, id: @participation.id, format: :json
  #     expect(response.code).to eq "403"     
  #   end

  #   it "should return 200 with participation data if user want to delete his new participation" do
  #     auth_headers = @participation.user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     delete :destroy, event_id: @participation.event.id, id: @participation.id, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @participation.id      
  #     expect(json["data"]["diet"]).to eq @participation.diet
  #     expect(json["data"]["other"]).to eq @participation.other      
  #   end

  #   it "should return 200 with participation data if super user want to delete a participation" do
  #   	auth_headers = @super_user.create_new_auth_token
  #     request.headers.merge!(auth_headers)
  #     delete :destroy, event_id: @participation.event.id, id: @participation.id, format: :json
  #     expect(response.code).to eq "200"
  #     expect(json["data"]["id"]).to eq @participation.id      
  #     expect(json["data"]["diet"]).to eq @participation.diet
  #     expect(json["data"]["other"]).to eq @participation.other      
  #   end
  # end
end
