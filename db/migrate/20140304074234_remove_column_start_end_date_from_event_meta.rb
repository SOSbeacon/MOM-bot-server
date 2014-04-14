class RemoveColumnStartEndDateFromEventMeta < ActiveRecord::Migration
  def up
    remove_column :event_meta, :start_date
    remove_column :event_meta, :end_date
  end
end
