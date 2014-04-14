class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.string :text
      t.string :photo_url
      t.string :audio_url
      t.string :groups, array: true, default: []

      t.timestamps
    end
  end
end
