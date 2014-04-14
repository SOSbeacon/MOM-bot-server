class AddUserIdToEvent < ActiveRecord::Migration
  def up
    add_column :events, :user_id, :integer
    add_index :events, :user_id
  end

  def down
  end
end
