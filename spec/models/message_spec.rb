require 'spec_helper'
require 'carrierwave/test/matchers'

describe Message do
  include CarrierWave::Test::Matchers

  let(:user) { FactoryGirl.create(:user) }

  before :each do
    @attr = {
      text: "Please help me!",
      lat: "111111111",
      lng: "5555555555",
      user_id: user.id
    }
  end

  describe 'should valid params' do
    before do
      @message = Message.create!(@attr)
    end

    subject {@message}

    it { should respond_to(:text) }
    it { should respond_to(:lat) }
    it { should respond_to(:lng) }
    it { should respond_to(:photo_url) }
    it { should respond_to(:audio_url) }
    it { should respond_to(:user_id) }
  end

  describe 'user id' do
    it 'blank' do
      no_user_id = Message.new(@attr.merge(:user_id => ''))
      no_user_id.should_not be_valid
    end

    it 'nil' do
      no_user_id = Message.new(@attr.merge(:user_id => nil))
      no_user_id.should_not be_valid
    end

    it 'does not exists' do
      no_user_id = Message.new(@attr.merge(:user_id => 123))
      no_user_id.should_not be_valid
    end
  end
end
