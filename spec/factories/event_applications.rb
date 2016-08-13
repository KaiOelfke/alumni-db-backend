FactoryGirl.define do
  factory :event_application, class: 'Event::Application' do
    motivation "MyText"
    cv_file "MyString"
    event nil
    user nil
  end
end
