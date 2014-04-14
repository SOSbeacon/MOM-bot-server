class AddLocationToMessage < ActiveRecord::Migration
  def up
    add_column :messages, :lng, :string
    add_column :messages, :lat, :string
  end
  def down
  end
end
