FactoryGirl.define do
  factory :application, :class => Events::Application do
    association :event, :factory => [:event, :with_application], strategy: :build
    association :user, factory: :user, strategy: :build
    motivation "I love this event"
  end
end
