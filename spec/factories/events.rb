FactoryGirl.define do
  factory :events_daily do |e|
    e.sequence(:title) { |n| "Event title #{n}" }
    e.sequence(:content) { |n| "Event content #{n}" }
    e.type_event "daily"
    e.start_time DateTime.parse("2012-03-03 07-00")
    e.end_time DateTime.parse("2012-03-03 09-00")
    e.end_date DateTime.parse("2012-04-03 00-00")
  end
end