FactoryGirl.define do
  factory :fee, :class => Events::Fee do
    name "MyString"
    price 1
    deadline Date.current + 1.month
    public_fee true
    delete_flag false
    association :event, :factory => [:event, :with_payment], strategy: :build
    
    trait :fee_codes do
      not_public
      after(:create) do |fee, evaluator|
        create_list(:fee_code, 3, fee: fee, event: fee.event)
      end      
    end

    trait :not_public do
      public_fee false
    end

  end
end
