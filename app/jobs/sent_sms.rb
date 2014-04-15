require 'resque/errors'

class SentSMS
  @queue = :send_sms_queue

  def self.perform(user_id, contact_phone, message_id)
    @twilio_client = Twilio::REST::Client.new TWILIO_SID, TWILIO_TOKEN
    user = User.find(user_id)
    @twilio_client.account.sms.messages.create(
        :from => "#{TWILIO_NUMBER}",
        :to => "+#{contact_phone}",
        :body => "#{user.last_name} #{user.first_name} called emergency 911. Link http://ms-robot.herokuapp.com/emergency/#{message_id}"
    )
  rescue Resque::TermException
    puts 'errors'
  end
end