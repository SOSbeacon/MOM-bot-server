# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contact do
    user
    group_contact
    sequence(:name) { |n| "contact_#{n}"}
    email "contact@gmail.com"
    phone "0973796065"
  end
end
