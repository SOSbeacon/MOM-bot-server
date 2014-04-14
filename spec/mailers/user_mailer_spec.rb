require 'spec_helper'

describe UserChildMailer do
  describe '#send_email_emergency' do
    let (:user) { FactoryGirl.create(:user) }
    let (:mail) { UserChildMailer.send_email_emergency(user, 'lhlong142@gmail.com') }

    it 'should have subject' do
      expect(mail.subject).to eq('EMERGENCY FROM MOM-BOT')
    end

    it 'should have receiver email' do
      expect(mail.to).to eq(['lhlong142@gmail.com'])
    end

    it 'should have sender email' do
      expect(mail.from).to eq(['msrobot2014@gmail.com'])
    end
  end
end