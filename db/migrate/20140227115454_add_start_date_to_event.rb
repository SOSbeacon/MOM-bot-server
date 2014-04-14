class AddStartDateToEvent < ActiveRecord::Migration

  def up
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime
  end

  def down
  end
end
