class AddUnconfirmedEmailToUserChildren < ActiveRecord::Migration
  def self.up
    add_column :user_children, :unconfirmed_email, :string
  end

  def self.down
    remove_column :user_children, :unconfirmed_email
  end

end
