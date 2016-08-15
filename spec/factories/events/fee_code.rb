FactoryGirl.define do
  factory :fee_code, :class => Events::FeeCode do
    sequence(:code) {|n| "a0#{n}123456789"}

    # association :fee, factory: :fee, strategy: :build
    # association :user, factory: :user, strategy: :build
    association :event, :factory => [:event, :with_application], strategy: :build

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

    trait :with_payment do
      after(:create) do |fee_code, evaluator|
        fee_code.event = create_list(:event, 1, :with_payment, fee_code: fee_code)
        create_list(:fee, 1, :not_public, fee_code: fee_code, event: fee_code.event)
      end
    end

    trait :with_application do
      after(:create) do |fee_code, evaluator|
        fee_code.event = create_list(:event, 1, :with_application, fee_code: fee_code)
      end
    end

    trait :with_payment_application do
      after(:create) do |fee_code, evaluator|
        fee_code.event = create_list(:event, 1, :with_payment_application, fee_code: fee_code)
        create_list(:fee, 1, :not_public, fee_code: fee_code, event: fee_code.event)
      end
    end
  end
end
