FactoryGirl.define do
  factory :event, :class => Event do
    sequence(:name) {|n| "Conference#{n}"}
    description "Awesome conference"
    location "Copenhagen"
    dates "11.11.16 - 13.13.16"
    delete_flag false    
    agenda "Agenda TBC"
    contact_email "nobody@alumnieurope.org"
    trait :published do
        published true
    end
  end
end
