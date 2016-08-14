FactoryGirl.define do
  factory :participation, :class => Events::Participation do

    #:new, :in_review, :approved, :paid


    trait :form do
      arrival Date.today + 1.month
      departure Date.today + 2.month
      allergies "no allergies"
      extra_nights "no extra nights"    
      other "nothing else to say"
      diet "no diet"
    end

    trait :appliaction do
      motivation "yee iam motivated"
      cv_file { Rack::Test::UploadedFile.new(File.join(Rails.root,'/spec','/support','/participations','/cv.pdf')) }
    end

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


    trait :with_application do
      association :event, factory: [:event, :with_application], strategy: :build

    end

    trait :without_application do 

      association :event, factory: [:event, :without_application], strategy: :build

    end

    association :fee, factory: :fee, strategy: :build
    association :user, factory: :user, strategy: :build

  end
end