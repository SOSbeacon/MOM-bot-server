class CreateEventMeta < ActiveRecord::Migration
  def change
    create_table :event_meta do |t|
      t.integer :event_id
      t.integer :repeat_start
      t.integer :repeat_interval

      t.timestamps
    end
    add_index :event_meta, :event_id
  end
end
