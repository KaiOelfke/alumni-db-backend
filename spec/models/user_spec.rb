require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data) }  

  describe 'Year of participation ' do

      it 'should be between 1.1.1900 and current year' do


        should accept_values_for(:year_of_participation, Date.parse('30.12.1993').year)
      end

      it 'should return error if its not in the allowed range' do

        #@user.year_of_participation = -1
        #expect( @user).to be_valid

        should_not accept_values_for(:year_of_participation, Date.parse('30.12.1800').year)
        should_not accept_values_for(:year_of_participation, (Date.today + 366).year)
      end      

  end


  describe 'Birthdate ' do

      it 'should be between 1.1.1900 and current year' do


        should accept_values_for(:date_of_birth, Date.parse('30.12.1993'))
      end

      it 'should return error if its not in the allowed range' do

        should_not accept_values_for(:date_of_birth, Date.parse('30.12.1800'))
        should_not accept_values_for(:date_of_birth, (Date.today + 366))
      end    

  end


  describe 'Country ' do

      it 'should be in the allowed list of countries' do

        should accept_values_for(:country_of_participation, "DE")
      end

      it 'should return error if its not in the allowed list' do

        should_not accept_values_for(:country_of_participation, "DEQ")
      end    
  end


end
