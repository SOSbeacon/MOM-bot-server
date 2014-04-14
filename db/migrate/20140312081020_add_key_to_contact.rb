class AddKeyToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :group_id, :integer
    add_column :group_contacts, :contact_ids, :string, array: true, default: []

    add_index :contacts, :group_id
  end

  def down
  end
end
