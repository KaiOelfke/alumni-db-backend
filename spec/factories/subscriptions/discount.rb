FactoryGirl.define do
  factory :discount, :class => Subscriptions::Discount do
    sequence(:name) {|n| "discount#{n}"}
    association :plan, factory: :plan, strategy: :build
    description 'description'
    sequence(:code) {|n| "15off#{n}"}
    price 15
    delete_flag false
    expiry_at Date.today

  end

end



