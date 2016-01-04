FactoryGirl.define do
  factory :user do

    sequence(:email) {|n| "e#{n}@example.com"}
    sequence(:uid) {|n| "uid#{n}"}

    password '12345678'
    password_confirmation '12345678'

    trait :subscribed do
      association :subscription, factory: :subscription
    end

    trait :personal_programm_data do

      first_name 'first_test'
      last_name 'last_test'
      country 'DE'
      city 'Berlin'
      date_of_birth Date.new(1995, 12, 3)
      gender 0

      program_type 0
      institution 'example institutation'
      year_of_participation 2006
      country_of_participation 'DE'
      student_company_name 'company name'

    end


    trait :confirmed_email do
        confirmed_at Time.now
        confirmed_email true
    end

    trait :registered do
        registered true
    end


    trait :completed_profile do
        completed_profile true
    end

    trait :super do
        is_super_user true
    end



    factory :user_with_groups do

      transient do
        groups_count 1
        is_admin false
        group_email_subscribed false
      end

      after(:create) do |user, evaluator|
          create_list(:membership, 1,is_admin: evaluator.is_admin, group_email_subscribed: false, user: user)

      end
    end
  end

end
