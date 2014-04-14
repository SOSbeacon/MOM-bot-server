class UserChildMailer < ActionMailer::Base
  default from: "msrobot2014@gmail.com"

  def send_new_user_child_message(user_child)
    @user_child = user_child
    mail(:to => user_child.email, :subject => "Welcome to msrobot")
  end

  def send_email_emergency(user, email, message_id)
    #debugger
    @user_child = user
    @email = email
    @message_id = message_id
    mail(:to => email, :subject => 'EMERGENCY FROM MOM-BOT')
  end

end