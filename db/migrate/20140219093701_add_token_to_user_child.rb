class AddTokenToUserChild < ActiveRecord::Migration
  def up
    add_column :user_children, :authentication_token, :string
    add_index :user_children, :authentication_token, :unique => true
  end

  def down
    remove_column :user_children, :authentication_token
  end

end
