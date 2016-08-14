FactoryGirl.define do
  factory :event, :class => Events::Event do
    sequence(:name) {|n| "Conference#{n}"}
    description "Awesome conference"
    location "Copenhagen"
    etype "without_application_payment"
    dates "11.11.16 - 13.13.16"
    delete_flag false    
    agenda "Agenda TBC"
    contact_email "nobody@alumnieurope.org"
    phone_number "0049123456789"
    published false
    slogan "ah"
    cover_photo { Rack::Test::UploadedFile.new(File.join(Rails.root,'/spec',
                                              '/support','/events','/cover-photo.png')) }
    logo_photo { Rack::Test::UploadedFile.new(File.join(Rails.root,'/spec',
                                              '/support','/events','/logo-256.jpg')) }

    trait :published do
      published true
    end

    trait :with_fees do
      after(:create) do |event, evaluator|
        create_list(:fee, 3, event: event)
        create_list(:fee, 1, :not_public, event: event)
      end      
    end

    trait :with_payment do
      etype "with_payment"
      published
      with_fees
    end

    trait :with_application do
      etype "with_application"
      published
    end

    trait :with_payment_application do
      etype "with_payment_application"
      published
      with_fees
    end    
  end
end
