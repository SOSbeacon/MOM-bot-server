class Contact < ActiveRecord::Base
  belongs_to :group_contact, :foreign_key => 'group_id', :class_name => 'GroupContact'
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'

  before_save :downcase_email

  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i, on: :create }, :allow_blank => true
  validates :name, :presence => true, :length => {:minimum => 1, :maximum => 50}
  validates :phone, :length => {:minimum => 9, :maximum => 13}, :numericality => {:only_integer => true}, :allow_blank => true

  validates :user_id, :presence => true
  validates_presence_of :user
  validate :check_exits_group
  validate :valid_email_phone

  def downcase_email
    self.email = self.email.downcase
  end

  def valid_email_phone
    if self.email == nil && self.phone == nil
      errors.add(:email, "You must fill email or phone field")
    elsif self.email == '' && self.phone == ''
      errors.add(:email, "You must fill email or phone field")
    end
  end

  def check_exits_group
    if self.group_id
      group_id = self.group_id
      group_contact = GroupContact.find_by_id(self.group_id)
      if !group_contact
        errors.add(:group_id, "group contact not found")
      end
    end
  end

  def response_contact
    group = GroupContact.where(:id => self.group_id).first
    contact = {
      id: self.id,
      user_id: self.user_id,
      email: self.email,
      name: self.name,
      phone: self.phone,
      group: nil
    }

    if group
      contact[:group] = {
        name: group.name,
        id: group.id
      }
    end

    return contact
  end

  #def as_json(options={})
  #  if self.group_id
  #    super.merge!({
  #      :group => {
  #        :id => self.group_contact.id,
  #        :name => self.group_contact.name
  #      }
  #    })
  #  else
  #    super
  #  end
  #end

end
