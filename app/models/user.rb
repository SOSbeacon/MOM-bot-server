class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  USER_NORMAL = 'normal'
  USER_PARENT = 'parent'
  has_many :events, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :group_contacts, :dependent => :destroy
  has_many :messages, :dependent => :destroy

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :authentication_keys => [:email]

  before_save :downcase_email, :ensure_authentication_token

  def downcase_email
    self.email = self.email.downcase
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end
    update_attributes(params)
  end

  validates :type_user, :inclusion => {:in => [User::USER_NORMAL, User::USER_PARENT]}, :if => Proc.new { |user| user.type_user} ## etc
  #validates :first_name, :presence => true, :length => {:minimum => 1, :maximum => 50}
  #validates :last_name, :presence => true, :length => {:minimum => 1, :maximum => 50}
end
