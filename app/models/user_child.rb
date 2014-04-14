class UserChild < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  #after_create :send_email_confirmation
  #before_save :ensure_authentication_token

  def send_email_confirmation
    UserChildMailer.send_new_user_child_message(self).deliver
  end

end
