require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :first_name => "Example",
      :last_name => "User",
      :email => "user@example.com",
      :password => "12345678",
      :password_confirmation => "12345678",
      :confirmed_at => Time.now
    }
  end

  describe "should create user with a valid param" do
    before do
      @user = User.create!(@attr)
    end

    subject { @user }

    it { should respond_to(:first_name) }
    it { should respond_to(:last_name) }
    it { should respond_to(:email) }
    it { should respond_to(:authentication_token) }

    it {should be_valid}
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should auto downcase email address" do
    u = User.create!({ :first_name => "Example", :last_name => "User", :email => "USer@cnc.vn", :password => "12345678", :password_confirmation => "12345678", :confirmed_at => Time.now})
    u.confirm!
    u.email.should eql('user@cnc.vn')
  end

  describe "password validations" do
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password => "aaaaaaaaaa", :password_confirmation => "bababababa")).should_not be_valid
    end

    it "should reject short passwords" do
      User.new(@attr.merge(:password => "12345", :password_confirmation => "12345")).should_not be_valid
    end

  end

  describe "should title validation" do
    it "invalid " do

    end
  end

end
