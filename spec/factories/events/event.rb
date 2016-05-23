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

    trait :without_application do
      etype "without_application"
    end

    trait :with_application do
      etype "with_application"
    end

    trait :with_fees do
      fees {[FactoryGirl.create(:fee),FactoryGirl.create(:fee),FactoryGirl.create(:fee)]}
    end
    
  end
end
