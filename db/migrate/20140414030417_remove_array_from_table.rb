class RemoveArrayFromTable < ActiveRecord::Migration
  def up
    remove_column :events, :days_of_week
    remove_column :event_meta, :array_repeat_interval
    remove_column :group_contacts, :contact_ids
    remove_column :messages, :groups
    remove_column :users, :owner_ids
  end
end
