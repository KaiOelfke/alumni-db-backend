FactoryGirl.define do
  factory :fee_code, :class => Events::FeeCode do
    sequence(:code) {|n| "a0#{n}123456789"}

    # association :fee, factory: :fee, strategy: :build
    # association :user, factory: :user, strategy: :build
    association :event, factory: :event, strategy: :build

    trait :with_user do
      after(:create) do |fee_code, evaluator|
        create_list(:user, 1, fee_code: fee_code)
      end      
    end

    trait :with_fee do
      after(:create) do |fee_code, evaluator|
        create_list(:fee, 1, fee_code: fee_code)
      end      
    end

  end
end
