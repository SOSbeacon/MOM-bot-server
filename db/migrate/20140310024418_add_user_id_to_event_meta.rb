class AddUserIdToEventMeta < ActiveRecord::Migration
  def up
    add_column :event_meta, :user_id, :integer
    add_index :event_meta, :user_id
  end
  def down
  end
end
