require 'spec_helper'

describe GroupContact do
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    @attr = {
      name: 'Group Contact A',
      user_id: user.id,
      contact_ids: []
    }
  end

  describe 'should valid params' do
    before do
      @group_contact = GroupContact.new(@attr)
    end

    subject {@group_contact}

    it { should respond_to(:name) }
    it { should respond_to(:user_id) }
    it { should respond_to(:contact_ids) }
    it { should be_valid }
  end

  describe 'user id' do
    it 'blank' do
      no_user_id = GroupContact.new(@attr.merge(:user_id => ''))
      no_user_id.should_not be_valid
    end

    it 'nil' do
      no_user_id = GroupContact.new(@attr.merge(:user_id => nil))
      no_user_id.should_not be_valid
    end

    it 'does not exists' do
      no_user_id = GroupContact.new(@attr.merge(:user_id => 123))
      no_user_id.should_not be_valid
    end
  end

  describe 'name' do
    it 'blank' do
      g_contact = GroupContact.new(@attr.merge(:name => ''))
      g_contact.should_not be_valid
    end

    it 'too long' do
      g_contact = GroupContact.new(@attr.merge(:name => ''*51))
      g_contact.should_not be_valid
    end

    it 'when nil' do
      g_contact = GroupContact.new(@attr.merge(:name => nil))
      g_contact.should_not be_valid
    end
  end

  describe 'user_id' do
    it 'blank' do
      g_contact = GroupContact.new(@attr.merge(:user_id => ''))
      g_contact.should_not be_valid
    end

    it 'when nil' do
      g_contact = GroupContact.new(@attr.merge(:user_id => nil))
      g_contact.should_not be_valid
    end
  end

end
