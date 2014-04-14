class AddConfirmedAtToUserChildren < ActiveRecord::Migration
  def self.up
    add_column :user_children, :confirmed_at, :datetime
    add_column :user_children, :confirmation_token, :string
    add_column :user_children, :confirmation_sent_at, :datetime
    add_index :user_children, :confirmation_token, :unique => true

    UserChild.update_all(:confirmed_at => Time.now)
  end

  def self.down
    remove_columns :user_children, :confirmed_at, :confirmation_sent_at, :confirmation_token
  end

end
