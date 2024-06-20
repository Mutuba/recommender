class ChangeNameColumnNullOnMovies < ActiveRecord::Migration[7.1]
  def change
    change_column_null :movies, :name, false
  end
end
