FactoryGirl.define do
  factory :membership do
    is_admin false
    position 'position'
    join_date Date.new(1995, 12, 3) 
    group_email_subscribed false



    trait :group_email_subscribed do 
        group_email_subscribed true
    end

  end

end
