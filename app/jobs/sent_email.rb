require 'resque/errors'

class SentEmail
  @queue = :send_email_queue

  def self.perform(user_id, contact_email, message_id)
    user = User.find(user_id)
    UserChildMailer.send_email_emergency(user, contact_email, message_id).deliver
  rescue Resque::TermException
    puts 'errors'
  end
end