FactoryGirl.define do
  factory :fee_code, :class => Events::FeeCode do
    sequence(:code) {|n| "a0#{n}123456789"}
    used_flag false
    # association :fee, factory: :fee, strategy: :build
    # association :user, factory: :user, strategy: :build
    association :event, :factory => [:event, :with_application], strategy: :build

    trait :with_user do
      after(:create) do |fee_code, evaluator|
        create_list(:user, 1)
      end      
    end

    trait :with_fee do
      after(:create) do |fee_code, evaluator|
        create_list(:fee, 1)
      end      
    end

    trait :with_payment do
      association :event, :factory => [:event, :with_payment], strategy: :build
      after(:build) do |fee_code, evaluator|
        fee_code.fee = create(:fee, :not_public, event: fee_code.event)
        fee_code.save
      end
    end

    trait :with_payment_application do
      association :event, :factory => [:event, :with_payment_application], strategy: :build
      after(:create) do |fee_code, evaluator|
        fee_code.fee = create(:fee, :not_public, event: fee_code.event)
        fee_code.save
      end
    end

    #fee_code for event with payment should always have a fee, just for testing
    trait :with_payment_and_no_fee do
      association :event, :factory => [:event, :with_payment], strategy: :build
    end

    trait :used do
      association :user, factory: :user, strategy: :build
      used_flag true
    end
  end
end
