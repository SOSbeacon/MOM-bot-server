class AddUserIdToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :user_id, :integer
    add_column :group_contacts, :user_id, :integer

    add_index :contacts, :user_id
    add_index :group_contacts, :user_id
  end

  def down
  end
end
