FactoryGirl.define do
  factory :membership do
    user
    group
    
    is_admin false
    position 'position'
    join_date Date.today
    group_email_subscribed false

    trait :group_email_subscribed do 
        group_email_subscribed true
    end

  end

end
