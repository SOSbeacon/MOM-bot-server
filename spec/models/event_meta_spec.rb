require 'spec_helper'

describe EventMeta do
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    @user = {
      :first_name => "Example",
      :last_name => "User",
      :email => "user@example.com",
      :password => "12345678",
      :password_confirmation => "12345678",
      :confirmed_at => Time.now,
      :type_user => "parent",
      :creator_id => user.id
    }
    @user = User.create!(@user)

    @event = {
      :title => "Example",
      :type_event => "daily",
      :content => "some event",
      :start_time => DateTime.parse("2012-12-12"),
      :end_time => DateTime.parse("2012-12-12"),
      :days_of_week => [],
      :end_date => DateTime.parse("2012-12-19"),
      :user_id => @user.id
    }
    @event = Event.create!(@event)

    @attr = {
      repeat_interval: 1,
      event_id: @event.id,
      repeat_start: DateTime.now,
      :user_id => @user.id
    }
  end
  describe "should create new event meta with valid param" do
    before do
      @event_meta = EventMeta.create!(@attr)
    end

    subject { @event_meta }

    it { should respond_to(:repeat_interval) }
    it { should respond_to(:event_id) }
    it { should respond_to(:repeat_start) }

    it { should be_valid }

  end

  it "should required repeat_interval for event" do
    no_repeat_interval = EventMeta.new(@attr.merge(:repeat_interval => nil))
    no_repeat_interval.should_not be_valid
  end

  it "should required event_id for event" do
    no_event_id = EventMeta.new(@attr.merge(:event_id => nil))
    no_event_id.should_not be_valid
  end

  it "should required repeat_start for event" do
    no_repeat_start = EventMeta.new(@attr.merge(:repeat_start => nil))
    no_repeat_start.should_not be_valid
  end

  it 'should require use_id' do
    no_use_id = EventMeta.new(@attr.merge(:user_id => nil))
    no_use_id.should_not be_valid
  end

  it "should repeat_interval > 0" do
    no_repeat_start = EventMeta.new(@attr.merge(:repeat_interval => -1000))
    no_repeat_start.should_not be_valid
  end

  it "should belong to event" do
    event_meta = EventMeta.new(@attr.merge(:event_id => "123"))
    event_meta.should_not be_valid
  end

  it "should invalid if user_id not exists" do
    event_meta = EventMeta.create(@attr.merge(:user_id => 123))
    event_meta.should_not be_valid
  end

end
