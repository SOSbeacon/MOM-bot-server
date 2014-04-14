FactoryGirl.define do
  factory :user do
    first_name "long"
    last_name "ly 01"
    sequence(:email) {|n| "email#{n}@factory.com" }
    password "12345678"
    password_confirmation "12345678"
    confirmed_at Time.now
    type_user 'normal'
  end

  factory :user_parent do
    first_name "parent"
    last_name "parent"
    sequence(:email) {|n| "parent#{n}@factory.com" }
    password "12345678"
    password_confirmation "12345678"
    confirmed_at Time.now
  end
end