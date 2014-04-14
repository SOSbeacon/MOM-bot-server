class ChangeStartDateFromEvent < ActiveRecord::Migration
  def up
    rename_column :events, :start_date, :start_time
    rename_column :events, :end_date, :end_time
    add_column :events, :end_date, :datetime
  end
end
