class RemoveArrayIntervalFromEventMeta < ActiveRecord::Migration
  def up
    add_column :events, :array_repeat_interval, :string, array: true, default: []
  end

  def down
    remove_column :event_meta, :array_repeat_interval, :string
  end
end
