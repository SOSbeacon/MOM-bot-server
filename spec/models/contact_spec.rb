require 'spec_helper'

describe Contact do
  let(:user) { FactoryGirl.create(:user) }

  before :each do
    @attr = {
        name: "Contact A",
        email: "contact@gmail.com",
        phone: "5555555555",
        user_id: user.id
    }
  end

  describe 'should valid params' do
    before do
      @contact = Contact.create!(@attr)
    end

    subject {@contact}

    it { should respond_to(:name) }
    it { should respond_to(:email) }
    it { should respond_to(:phone) }
    it { should respond_to(:group_id) }
    it { should respond_to(:user_id) }
  end

  describe 'user id' do
    it 'blank' do
      no_user_id = Contact.new(@attr.merge(:user_id => ''))
      no_user_id.should_not be_valid
    end

    it 'nil' do
      no_user_id = Contact.new(@attr.merge(:user_id => nil))
      no_user_id.should_not be_valid
    end

    it 'does not exists' do
      no_user_id = Contact.new(@attr.merge(:user_id => 123))
      no_user_id.should_not be_valid
    end
  end

  describe 'name' do
    it 'blank' do
      no_name = Contact.new(@attr.merge(:name => ''))
      no_name.should_not be_valid
    end

    it 'is too long' do
      name_too_long = Contact.new(@attr.merge(:name => 'a'*51))
      name_too_long.should_not be_valid
    end

    it 'when nil' do
      no_name = Contact.new(@attr.merge(:name => nil))
      no_name.should_not be_valid
    end
  end

  describe 'email' do
    it 'wrong format' do
      email_format = %w[user@foo,com user_at_foo.org example.user@foo.]
      email_format.each do |e|
        contact = Contact.new(@attr.merge(:email => e))
        contact.should_not be_valid
      end
    end

    it 'valid format' do
      email_format = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      email_format.each do |e|
        contact = Contact.new(@attr.merge(:email => e))
        contact.should be_valid
      end
    end
  end

  describe 'phone' do
    it 'too long' do
      contact = Contact.new(@attr.merge(:phone => '1'*14))
      contact.should_not be_valid
    end

    it 'too short' do
      contact = Contact.new(@attr.merge(:phone => '123'))
      contact.should_not be_valid
    end

    it 'contain char' do
      contact = Contact.new(@attr.merge(:phone => '0973796065a'))
      contact.should_not be_valid
    end
  end

  describe 'email and phone' do
    it 'should not nil together' do
      contact = Contact.new(@attr.merge(:phone => nil, :email => nil))
      contact.should_not be_valid
    end

    it 'should not blank together' do
      contact = Contact.new(@attr.merge(:phone => '', :email => ''))
      contact.should_not be_valid
    end

    it 'should have phone and blank email' do
      contact = Contact.new(@attr.merge(:phone => '09737960652'.to_i, :email => nil))
      contact.should be_valid
    end

    it 'should have email and blank phone' do
      contact = Contact.new(@attr.merge(:phone => nil, :email => 'contact@gmail.com'))
      contact.should be_valid
    end
  end

end
