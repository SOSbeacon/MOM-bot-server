require 'spec_helper'

describe "events/new" do
  before(:each) do
    assign(:event, stub_model(Event,
      :title => "MyString",
      :type => "",
      :content => "MyString"
    ).as_new_record)
  end

  it "renders new event form" do
    render

    assert_select "form[action=?][method=?]", events_path, "post" do
      assert_select "input#event_title[name=?]", "event[title]"
      assert_select "input#event_type[name=?]", "event[type]"
      assert_select "input#event_content[name=?]", "event[content]"
    end
  end
end
