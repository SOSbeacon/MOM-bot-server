class RenameArrayIntervalFromEvent < ActiveRecord::Migration
  def up
    rename_column :events, :array_repeat_interval, :days_of_week
  end
end
