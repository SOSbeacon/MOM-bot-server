class AddDefaultValueToTypeUser < ActiveRecord::Migration
  def up
    change_column_default :users, :type_user, "normal"
  end

  def down
    change_column_default :users, :type_user, nil
  end
end
