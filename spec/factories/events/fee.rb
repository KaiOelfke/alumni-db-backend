FactoryGirl.define do
  factory :fee, :class => Events::Fee do
    name "MyString"
    price 1
    deadline "2016-03-21"
    association :event, factory: :event, strategy: :build

    trait :fee_codes do
    	fee_codes {[FactoryGirl.create(:fee_code),
    							FactoryGirl.create(:fee_code),
    							FactoryGirl.create(:fee_code)]}
   	end

  end
end
