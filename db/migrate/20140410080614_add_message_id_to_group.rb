class AddMessageIdToGroup < ActiveRecord::Migration
  def up
    add_column :group_contacts, :message_id, :integer
    add_index :group_contacts, :message_id
  end
  def down
  end
end
