FactoryGirl.define do
  factory :event, :class => Events::Event do
    sequence(:name) {|n| "Conference#{n}"}
    description "Awesome conference"
    location "Copenhagen"
    etype "without_application"
    dates "11.11.16 - 13.13.16"
    delete_flag false    
    agenda "Agenda TBC"
    contact_email "nobody@alumnieurope.org"
    published false
    slogan "ah"
    trait :published do
        published true
    end

    trait :without_application do
      etype "without_application"
    end

    trait :with_application do
      etype "with_application"
    end

    trait :with_fees do
      fees {[FactoryGirl.create(:fee)]}
    end    
  end
end
