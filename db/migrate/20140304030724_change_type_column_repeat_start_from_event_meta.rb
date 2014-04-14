class ChangeTypeColumnRepeatStartFromEventMeta < ActiveRecord::Migration
  def up
    remove_column :event_meta, :repeat_start
    add_column :event_meta, :repeat_start, :datetime
  end
  def down
  end
end
