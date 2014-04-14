class CreateGroupContacts < ActiveRecord::Migration
  def up
    create_table :group_contacts do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :group_contacts
  end
end
