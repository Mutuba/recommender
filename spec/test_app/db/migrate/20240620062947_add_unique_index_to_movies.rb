class AddUniqueIndexToMovies < ActiveRecord::Migration[7.1]
  def change
    add_index :movies, :name, unique: true
  end
end
