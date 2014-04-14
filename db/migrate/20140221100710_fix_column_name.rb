class FixColumnName < ActiveRecord::Migration

  def self.up
    rename_column :users, :belong_id, "creator_id"
  end

  def self.down

  end

end
