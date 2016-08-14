FactoryGirl.define do
  factory :fee, :class => Events::Fee do
    name "MyString"
    price 1
    deadline Date.current + 1.month
    public_fee true
    delete_flag false
    association :event, factory: :event, strategy: :build 
    trait :fee_codes do
    	fee_codes {[FactoryGirl.create(:fee_code),
    							FactoryGirl.create(:fee_code),
    							FactoryGirl.create(:fee_code)]}
   	end

  end
end
