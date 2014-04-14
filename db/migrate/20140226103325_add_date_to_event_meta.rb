class AddDateToEventMeta < ActiveRecord::Migration
  def up
    add_column :event_meta, :start_date, "bigint NOT NULL"
    add_column :event_meta, :end_date, "bigint NOT NULL"
  end

  def down
  end
end
