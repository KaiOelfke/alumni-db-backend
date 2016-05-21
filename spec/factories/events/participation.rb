FactoryGirl.define do
  factory :participation, :class => Events::Participation do

    #:new, :in_review, :approved, :paid
    status "submitted"
    arrival Date.today + 1.month
    departure Date.today + 2.month
    allergies "no allergies"
    extra_nights "no extra nights"    
    other "nothing else to say"
    diet "no diet"

    trait :submitted do 
      status "submitted"
    end

    trait :in_review do 
      status "in_review"
    end

    trait :approved do
      status "approved"
    end

    trait :paid do
      status "paid"
      braintree_transaction_id 123
    end

    association :fee, factory: :fee, strategy: :build
    association :user, factory: :user, strategy: :build
    association :event, factory: :event, strategy: :build

  end
end
