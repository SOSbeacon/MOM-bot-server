require 'spec_helper'

describe "Events" do
  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before :each do
    @url_list_event = "/event/list_event_on_range_date.json"

    @parent = User.create!({
      :first_name => "Example",
      :last_name => "User",
      :email => "user@example.com",
      :password => "12345678",
      :password_confirmation => "12345678",
      :confirmed_at => Time.now,
      :creator_id => user.id,
      :type_user => "parent"
    })

    @attr = {
      :title => "Example",
      :type_event => "norepeat",
      :content => "some event",
      :start_time => DateTime.now.change(:hour => 7),
      :end_time => DateTime.now.change(:hour => 8),
      :days_of_week => nil,
      :end_date => DateTime.now.next_month,
      :repeat_interval => 1,
      :user_id => @parent.id
    }
  end

  describe "#get_event_from_date_to_date" do
    it "should response 400 if param have not query_start" do
      get @url_list_event + "?user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
      response.status.should be(400)
    end

    it "should response 400 if param have not query_start" do
      get @url_list_event + "?query_start=#{DateTime.now.beginning_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
      response.status.should be(400)
    end

    it "should response 400 if param have not query_start" do
      get @url_list_event + "?query_end=#{DateTime.now.end_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
      response.status.should be(400)
    end

    describe "check valid field response" do
      before do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "daily")
      end

      it "should response list event with valid param" do
        get @url_list_event + "?query_end=#{DateTime.now.end_of_month}&query_start=#{DateTime.now.beginning_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
        response.status.should be(200)
      end

      it "should response 9 field" do
        get @url_list_event + "?query_end=#{DateTime.now.end_of_month}&query_start=#{DateTime.now.beginning_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
        parsed_body = JSON.parse(response.body)
        parsed_body[0].should have(10).items
        parsed_body[0].key?("_id").should be_true
        parsed_body[0].key?("start").should be_true
        parsed_body[0].key?("end").should be_true
        parsed_body[0].key?("title").should be_true
        parsed_body[0].key?("type_event").should be_true
        parsed_body[0].key?("content").should be_true
        parsed_body[0].key?("created_at").should be_true
        parsed_body[0].key?("updated_at").should be_true
        parsed_body[0].key?("user_id").should be_true
        parsed_body[0].key?("end_date").should be_true
      end
    end

    describe "with daily and interval 1 days" do
      before do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "daily")
      end

      it "should response 26 times in current month" do
        get @url_list_event +"?query_end=#{DateTime.now.end_of_month}&query_start=#{DateTime.now.beginning_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
        parsed_body = JSON.parse(response.body)
        parsed_body.count.should be(DateTime.now.end_of_month.strftime("%d").to_i - DateTime.now.strftime("%d").to_i + 1)
      end

      it "should response 9 times in next month" do
        get @url_list_event + "?query_start=#{DateTime.now.next_month.beginning_of_month}&query_end=#{DateTime.now.next_month.end_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
        parsed_body = JSON.parse(response.body)
        parsed_body.count.should be(DateTime.now.next_month.strftime("%d").to_i - DateTime.now.next_month.beginning_of_month.strftime("%d").to_i + 1)
      end
    end

    describe "with weekly and interval 1 weeks and repeat on day" do
      before do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "weekly", :days_of_week => ['6','0'])
      end

      it "should response 9 times in next month" do
        get @url_list_event + "?query_start=#{DateTime.now.next_month.beginning_of_month}&query_end=#{DateTime.now.next_month.end_of_month}&user_id=#{@parent.id}&auth_token=#{user.authentication_token}"
        response.status.should be(200)
      end
    end

  end

  describe "#create" do
    it "should resonse 400 if missing title" do
      post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:title => "")
      response.status.should be(422)
    end

    it "should resonse 400 if missing start_time" do
      post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:start_time => "")
      response.status.should be(422)
    end

    it "should resonse 400 if missing end_time" do
      post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:end_time => "")
      response.status.should be(422)
    end

    describe "event type is daily" do
      it "should create new event meta" do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "daily")
        response.status.should be(201)
      end
    end

    describe "event type is weekly" do
      it "should create new event meta" do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "weekly", :days_of_week => ['0','2'])
        response.status.should be(201)
      end
    end

  end
  #
  describe "#delete" do
    before :each do
      @event = Event.create!(@attr.except!(:repeat_interval).merge(:user_id => @parent.id))
    end

    it "should response status 400 with no permission" do
      delete "/events/#{@event.id}.json?auth_token=#{other_user.authentication_token}", :event => {:id => @event.id}
      response.status.should be(400)
    end

    it "should response status 204 when user delete" do
      delete "/events/#{@event.id}.json?auth_token=#{user.authentication_token}", :event => {:id => @event.id}
      response.status.should be(204)
    end

    it "should response status 204 when parent delete" do
      delete "/events/#{@event.id}.json?auth_token=#{@parent.authentication_token}", :event => {:id => @event.id}
      response.status.should be(204)
    end
  end

  describe "#update" do
    describe 'should update weekly event with valid params' do
      before do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "weekly", :days_of_week => ['0','2'])
        event_id = JSON.parse(response.body)[0]["_id"]
        put "/events/#{event_id}.json?auth_token=#{user.authentication_token}", { :event => @attr.merge({:type_event => "weekly", :title => "edit title", :repeat_interval => 2, :days_of_week => ['0','2','3']}) }
      end

      it 'response' do
        response.status.should be(201)
      end

      it 'check event' do
        Event.where(:id => Event.first.id).first.title.should eql("edit title")
      end

      it 'check event mata' do
        EventMeta.where(:event_id => Event.first.id).count.should be(3)
        event_metas = EventMeta.where(:event_id => Event.first.id)
        event_metas.each do |em|
          em.repeat_interval.should be(2)
        end
      end

    end

    describe 'should update daily event with valid params' do
      before do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "daily", :repeat_interval => 3)
        event_id = JSON.parse(response.body)[0]["_id"]
        put "/events/#{event_id}.json?auth_token=#{user.authentication_token}", { :event => @attr.merge({:type_event => "daily", :title => "edit title", :repeat_interval => 2}) }
      end

      it 'response' do
        response.status.should be(201)
      end

      it 'check event' do
        Event.where(:id => Event.first.id).first.title.should eql("edit title")
      end

      it 'check event mata' do
        EventMeta.where(:event_id => Event.first.id).count.should be(1)
        EventMeta.where(:event_id => Event.first.id).first.repeat_interval.should be(2*INTERVAL_DAILY)
      end
    end

    describe "should parent can update event" do
      before do
        post "/events.json?auth_token=#{user.authentication_token}", :event => @attr.merge(:type_event => "daily", :repeat_interval => 3)
        event_id = JSON.parse(response.body)[0]["_id"]
        put "/events/#{event_id}.json?auth_token=#{@parent.authentication_token}", { :event => @attr.merge({:type_event => "daily", :title => "edit title", :repeat_interval => 2}) }
      end

      it 'response' do
        response.status.should be(201)
      end

      it 'check event' do
        Event.where(:id => Event.first.id).first.title.should eql("edit title")
      end

      it 'check event mata' do
        EventMeta.where(:event_id => Event.first.id).count.should be(1)
        EventMeta.where(:event_id => Event.first.id).first.repeat_interval.should be(2*INTERVAL_DAILY)
      end

    end

    describe "should not update event if not child user or parent user" do
      before do
        @event = Event.create!(@attr.except!(:repeat_interval).merge(:user_id => @parent.id))
        put "/events/#{@event.id}.json?auth_token=#{other_user.authentication_token}", { :event => @attr.merge({:type_event => "daily", :title => "edit title", :repeat_interval => 2}) }
      end

      it 'response' do
        response.status.should be(400)
      end

    end

  end

end
