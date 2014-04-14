class EventMeta < ActiveRecord::Base
  belongs_to :event, :foreign_key => "event_id", :class_name => "Event"
  belongs_to :user, :foreign_key => "user_id", :class_name => "User"
  #before_save :set_repeat_interval

  validates :repeat_interval, :presence => true, :numericality => {only_integer: true, :greater_than_or_equal_to => 1}
  validates :event_id, :presence => true
  validates :repeat_start, :presence => true
  validates :user_id, :presence => true
  validates_presence_of :user
  validates_presence_of :event

  def set_repeat_interval
    self.repeat_interval = self.repeat_interval*INTERVAL_DAILY
  end
end
