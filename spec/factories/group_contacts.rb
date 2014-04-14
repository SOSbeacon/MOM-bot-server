# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group_contact do
    user
    sequence(:name) { |n| "group_contact_#{n}"}
  end
end
