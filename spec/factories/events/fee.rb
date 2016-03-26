FactoryGirl.define do
  factory :fee, :class => Events::Fee do
    name "MyString"
    price 1
    deadline "2016-03-21"
    association :event, factory: :event, strategy: :build
  end
end
