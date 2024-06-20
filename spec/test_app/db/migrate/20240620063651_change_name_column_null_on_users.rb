class ChangeNameColumnNullOnUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :name, false
  end
end
