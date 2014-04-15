class Event < ActiveRecord::Base
  has_many :event_metas, :dependent => :destroy
  belongs_to :user, :foreign_key => 'user_id', :class_name => 'User'
  serialize :days_of_week, Array

  validates :type_event, presence: true, inclusion: {in: %w(daily weekly monthly yearly norepeat), message: "%{value} is not valid type"}
  validates :title, presence: true, :length => {:minimum => 1, :maximum => 500}
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :user_id, presence: true

  DAYS_OF_WEEK = %w[0 1 2 3 4 5 6] + [nil]
  validate :days_check

  validates_presence_of :user
  #before_save :check_end_date

  # tra ve so event trong khoang thoi gian start_time va end_time
  def query_event(query_end, query_start)
    # start_time: thoi diem bat dau event
    # end_time: thoi diem ket thuc event hoac la thoi diem client gui len query_time
    start_time = self.start_time.to_datetime
    if !self.end_date
      end_date = query_end
    else
      end_date = self.end_date.to_datetime
    end
    events_response = Array.new

    if query_start.strftime("%m").to_i > end_date.strftime("%m").to_i
      return events_response
    else
      if query_start.strftime("%Q").to_i > self.start_time.to_datetime.strftime("%Q").to_i
        start_time = query_start
      end
      end_time = [query_end, end_date].min
    end

    #debugger

    # check loai event la daily, weekly hay monthly
    if self.type_event == 'daily'
      # number_date: la so luong event tra ve trong khoang thoi gian start_time toi end_time voi thoi gian lap la
      # repeat_interval
      repeat_interval = self.event_metas[0].repeat_interval.to_i
      number_date = (end_time.to_datetime.strftime("%Q").to_i - start_time.to_datetime.strftime("%Q").to_i + INTERVAL_DAILY)/repeat_interval.round
      #debugger
      # tao event tra ve voi so lan lap la number_date
      (0..(number_date-1)).each do |i|
        event_custom = {
          _id: self.id.to_s,
          start: (self.start_time.to_datetime.change(:month => start_time.strftime("%m").to_i, :day => start_time.strftime("%d").to_i) + (repeat_interval*i/INTERVAL_DAILY).days).strftime("%Y-%m-%dT%H:%M:%S%z"),
          end: (self.end_time.to_datetime.change(:month => start_time.strftime("%m").to_i, :day => start_time.strftime("%d").to_i) + (repeat_interval*i/INTERVAL_DAILY).days).strftime("%Y-%m-%dT%H:%M:%S%z"),
          title: self.title,
          type_event: self.type_event,
          content: self.content,
          created_at: self.created_at,
          updated_at: self.updated_at,
          user_id: self.user_id,
          end_date: self.end_date
        }
        events_response.push(event_custom)
      end


    elsif self.type_event == 'weekly'
      event_metas = self.event_metas
      #number_date = ((end_time.strftime("%Q").to_i - start_time.strftime("%Q").to_i).to_f/INTERVAL_WEEKLY.to_f).ceil

      #debugger

      event_metas.each do |meta|
        day = meta.repeat_start.to_datetime.strftime("%w")
        number_interval = meta.repeat_interval
        days = find_all_day_in_range_time(start_time, end_time, day, number_interval)
        days.each do |d|
          event_custom = {
            _id: self.id.to_s,
            start: d.change({:hour => self.start_time.to_datetime.strftime("%H").to_i, :min => self.start_time.to_datetime.strftime("%M").to_i}).strftime("%Y-%m-%dT%H:%M:%S%z"),
            end: d.change({:hour => self.end_time.to_datetime.strftime("%H").to_i, :min => self.end_time.to_datetime.strftime("%M").to_i}).strftime("%Y-%m-%dT%H:%M:%S%z"),
            title: self.title,
            type_event: self.type_event,
            content: self.content,
            created_at: self.created_at,
            updated_at: self.updated_at,
            user_id: self.user_id,
            end_date: self.end_date,
            days_of_week: self.days_of_week
          }
          #debugger
          events_response.push(event_custom)
        end
        #(0..(number_date-1)).each do |i|
        #  event_custom = {
        #    _id: self.id.to_s,
        #    start: (meta.repeat_start.change(:month => start_time.strftime("%m").to_i) + 7*i.days).strftime("%Y-%m-%dT%H:%M:%S%z"),
        #    end: (meta.repeat_start.change({:month => start_time.strftime("%m").to_i, :hour => self.end_time.to_datetime.strftime("%H").to_i, :min => self.end_time.to_datetime.strftime("%M").to_i})+ 7*i.days).strftime("%Y-%m-%dT%H:%M:%S%z"),
        #    title: self.title,
        #    type_event: self.type_event,
        #    content: self.content,
        #    created_at: self.created_at,
        #    updated_at: self.updated_at,
        #    user_id: self.user_id
        #  }
        #  #debugger
        #  events_response.push(event_custom)
        #end
      end
    else

      if (query_start..query_end).cover? self.start_time
        event_custom = {
          _id: self.id,
          start: self.start_time.strftime("%Y-%m-%dT%H:%M:%S%z"),
          end: self.end_time.strftime("%Y-%m-%dT%H:%M:%S%z"),
          title: self.title,
          type_event: self.type_event,
          content: self.content,
          created_at: self.created_at,
          updated_at: self.updated_at,
          user_id: self.user_id,
          end_date: self.end_date
        }
        events_response.push(event_custom)
      end
    end
    return events_response
  end

  def convert_millisecond_to_date(milisecond)
    t = Time.at(milisecond/1000)
    DateTime.parse(t.to_s)
  end

  def days_check
    #debugger
    if self.days_of_week && self.type_event == 'weekly'
      self.days_of_week.each do |m|
        errors.add(:days_of_week, "#{m} is no a valid day") unless DAYS_OF_WEEK.include? m
      end

      if self.days_of_week.uniq.length != self.days_of_week.length
        errors.add(:days_of_week, "a does contain duplicates")
      end


      if self.days_of_week.count == 0
        errors.add(:days_of_week, "must have value")
      end
    end
  end

  def check_end_date
    self.end_date = DateTime.parse("2222-12-12")
    #debugger
  end

  # find all day in range time, such as: find all monday in range time
  def find_all_day_in_range_time(start_time, end_time, day, number_interval)
    d = start_time
    days = Array.new
    while d.strftime("%D") <= end_time.strftime("%D") do
      if d.strftime("%w").to_i == day.to_i
        days.push(d)
        d = d + number_interval.weeks
      else
        d = d + 1.days
      end
    end
    return days
  end

end
