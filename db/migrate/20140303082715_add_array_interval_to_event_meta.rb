class AddArrayIntervalToEventMeta < ActiveRecord::Migration
  def up
    add_column :event_meta, :array_repeat_interval, :string, array: true, default: []
  end

  def down
  end
end
