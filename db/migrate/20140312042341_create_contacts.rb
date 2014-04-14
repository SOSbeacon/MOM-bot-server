class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end

  def down
    drop_table :contacts
  end
end
