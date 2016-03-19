FactoryGirl.define do
  factory :subscription, :class => Subscriptions::Subscription do
    braintree_transaction_id 123
    created_at Date.today
    association :plan, factory: :plan
    association :discount, factory: :discount

  end

end
