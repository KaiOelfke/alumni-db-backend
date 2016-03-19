FactoryGirl.define do
  factory :plan, :class => Subscriptions::Plan do
    sequence(:name) {|n| "plan#{n}"}
    description 'description'
    price 25
    default false
    delete_flag false


    trait :default do
      default true
    end

  end

end
