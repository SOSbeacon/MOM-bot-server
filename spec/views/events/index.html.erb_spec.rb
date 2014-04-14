require 'spec_helper'

describe "events/index" do
  before(:each) do
    assign(:events, [
      stub_model(Event,
        :title => "Title",
        :type => "Type",
        :content => "Content"
      ),
      stub_model(Event,
        :title => "Title",
        :type => "Type",
        :content => "Content"
      )
    ])
  end

  it "renders a list of events" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Content".to_s, :count => 2
  end
end
