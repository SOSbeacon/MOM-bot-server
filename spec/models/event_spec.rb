require 'spec_helper'

describe Event do
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

    @attr = {
      :title => "Example",
      :type_event => "daily",
      :content => "some event",
      :start_time => DateTime.parse("2012-12-12"),
      :end_time => DateTime.parse("2012-12-12"),
      :days_of_week => [],
      :end_date => DateTime.parse("2012-12-19"),
      :user_id => @user.id
    }
    @event = Event.create!(@attr)
  end

  subject { @event }

  #it { should have_many(:event_metas) }
  it {should be_valid}


  it "should required title for event" do
    no_title = Event.new(@attr.merge(:title => ""))
    no_title.should_not be_valid
  end

  it "should required start time for event" do
    no_start_time = Event.new(@attr.merge(:start_time => ""))
    no_start_time.should_not be_valid
  end

  it "should required end time for event" do
    no_end_time = Event.new(@attr.merge(:end_time => ""))
    no_end_time.should_not be_valid
  end

  it 'should required user_id' do
    no_user_id = Event.new(@attr.merge(:user_id => nil))
    no_user_id.should_not be_valid
  end

  it "should type event inclusion valid values" do
    %w(daily weekly monthly yearly norepeat).each do |type|
      @event.type_event = type
      @event.days_of_week = ['1']
      @event.should be_valid
    end
  end

  it "should type event invalid with " do
    %w(hello, word).each do |type|
      @event.type_event = type
      @event.should_not be_valid
    end
  end

  it "should type event inclusion valid values" do
    days_of_week = Event.new(@attr.merge(:days_of_week => ['2','3'], :type_event => "weekly"))
    days_of_week.should be_valid
  end

  it "should duplication value" do
    days_of_week = Event.new(@attr.merge(:days_of_week => ['2','2'], :type_event => "weekly"))
    days_of_week.should_not be_valid
  end

  it "should type event inclusion invalid values" do
    days_of_week = Event.new(@attr.merge(:days_of_week => ['8','9'], :type_event => "weekly"))
    days_of_week.should_not be_valid
  end

  it "should invalid if nil days_of_week" do
    days_of_week = Event.new(@attr.merge(:type_event => "weekly"))
    days_of_week.should_not be_valid
  end

  it "should valid if valid value days_of_week" do
    days_of_week = Event.new(@attr.merge(:type_event => "weekly", :days_of_week => ['1','2']))
    days_of_week.should be_valid
  end

  it "should invalid if user_id not exists" do
    event = Event.create(@attr.merge(:user_id => 123))
    event.should_not be_valid
  end

  describe "should title length" do
    it "minimum title" do
      @event.title = "a"*50
      @event.should be_valid
    end

    it "invalid length" do
      @event.title = "a"*1000
      @event.should_not be_valid
    end
  end

end
