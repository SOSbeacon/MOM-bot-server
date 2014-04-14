class GroupContact < ActiveRecord::Base
  has_many :contacts, :foreign_key => 'group_id', :class_name => 'Contact', :dependent => :destroy
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'

  validates :name, :presence => true, :length => {:minimum => 1, :maximum => 50}
  validates :user_id, :presence => true
  validates_presence_of :user


  def response_format
    {
      id: self.id,
      name: self.name,
      user_id: self.user_id,
      created_at: self.created_at,
      updated_at: self.updated_at
    }
  end

  def response_format_with_contact
    contacts = self.contacts
    response = Array.new

    contacts.each do |c|
      data = {
        id: c.id,
        name: c.name
      }
      response.push(data)
    end

    group_contact = {
      id: self.id,
      name: self.name,
      user: self.user,
      contacts: response,
      created_at: self.created_at,
      updated_at: self.updated_at
    }

    return group_contact
  end

  def as_json(options={})
    if self.contacts
      super.merge!(
        {
          :contacts => self.contacts.as_json,
          :user => self.user,
          :total_contact => self.contacts.count
        }
      )
    end
  end
end
