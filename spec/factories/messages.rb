# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    user
    user_id "MyString"
    text "MyString"
    lat "123123123"
    lng "asdfasdf"
    after(:build) do |user, eval|
      message.photo_url << FactoryGirl.build(:photo_file, message: message)
    end
  end
end
