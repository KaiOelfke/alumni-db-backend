FactoryGirl.define do
  factory :group do
    sequence(:name) {|n| "name#{n}"}

    description 'description'
    group_email_enabled false

    trait :group_email_enabled do
      group_email_enabled:true
    end

  end

end
