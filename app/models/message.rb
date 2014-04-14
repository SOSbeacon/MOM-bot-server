class Message < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
  has_many :group_contacts, :foreign_key => 'message_id', :class_name => 'GroupContact'

  mount_uploader :photo_url, PhotoUploader
  mount_uploader :audio_url, AudioUploader

  validates :user_id, :presence => true
  validates_presence_of :user
end
