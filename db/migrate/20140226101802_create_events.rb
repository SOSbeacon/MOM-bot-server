class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :type_event
      t.string :content

      t.timestamps
    end
  end
end
