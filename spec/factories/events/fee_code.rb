FactoryGirl.define do
  factory :fee_code, :class => Events::FeeCode do
    sequence(:code) {|n| "a0#{n}123456789"}

    association :fee, factory: :fee, strategy: :build
    association :user, factory: :user, strategy: :build
  end
end
