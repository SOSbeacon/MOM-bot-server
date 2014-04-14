require 'resque/errors'

class SentSMS
  @queue = :send_sms_queue

  def self.perform(user_id, contact_phone, message_id)
    @twilio_client = Twilio::REST::Client.new TWILIO_SID, TWILIO_TOKEN
    @twilio_client.account.sms.messages.create(
        :from => "#{TWILIO_NUMBER}",
        :to => "+#{contact_phone}",
        :body => "This is an message. It gets sent to MOM-BOT. Link http://ms-robot.herokuapp.com/emergency/#{message_id}"
    )
  rescue Resque::TermException
    puts 'errors'
  end
end