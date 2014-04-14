class AddDayOfWeekToEvent < ActiveRecord::Migration
  def up
    add_column :events, :days_of_week, :string
  end
end
