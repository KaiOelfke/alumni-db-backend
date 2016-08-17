FactoryGirl.define do
  factory :participation, :class => Events::Participation do
    association :user, factory: :user, strategy: :build
    trait :form do
      arrival "TXL 10.10.10"
      departure "TXL 20.10.10"
      allergies "no allergies"
      extra_nights "no extra nights"    
      other "nothing else to say"
      diet "no diet"
    end
    
    trait :paid do
      braintree_transaction_id 123
    end
    
    trait :without_application_payment do
      association :event, factory: :event, strategy: :build
    end

    trait :with_payment do
      association :event, :factory => [:event, :with_payment], strategy: :build
      after(:build) do |participation|
        participation.fee = create(:fee, event: participation.event)
        participation.save
      end
      paid
    end

    trait :with_application do
      association :event, :factory => [:event, :with_application], strategy: :build
      after(:build) do |participation|
        participation.fee_code = create(:fee_code, event: participation.event)
        participation.save
      end
    end

    trait :with_payment_application do
      association :fee, factory: :fee, strategy: :build
      association :event, :factory => [:event, :with_payment_application], strategy: :build
      after(:build) do |participation|
        fee = participation.fee
        fee.event_id = participation.event
        fee.public_fee = false
        fee.save
        participation.fee_code = create(:fee_code, event: participation.event, fee: fee)
        participation.save
      end
      paid
    end

    # trait :with_special_fee do
    #   association :fee, factory: [:fee, :fee_codes], strategy: :build
    #   association :event, :factory => [:event, :with_payment], strategy: :build
    #   after(:create) do |participation, evaluator|
    #     create_list(:fee_code, 3, fee: fee, event: fee.event)
    #   end
    # end

  end
end
