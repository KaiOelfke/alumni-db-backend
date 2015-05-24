FactoryGirl.define do
  factory :group do
    sequence(:name) {|n| "name#{n}"}

    description 'description'
    group_email_enabled false

    trait :group_email_enabled do
      group_email_enabled:true
    end

   factory :group_with_user do

      transient do
        users_count 1
      end

      after(:create) do |group, evaluator|
        list = []
        user = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)
        admin = FactoryGirl.create(:user, :registered, :completed_profile, :confirmed_email, :personal_programm_data)

        mAdmin = FactoryGirl.create(:membership, is_admin: true, group: group, user:admin)
        mUser = FactoryGirl.create(:membership, is_admin: true, group: group, user:user)
        list.push mAdmin
        list.push user
        #FactoryGirl.create_list(:membership, evaluator.users_count, group: group)
        list
      end
   end

  end

end
