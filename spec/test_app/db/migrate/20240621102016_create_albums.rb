class CreateAlbums < ActiveRecord::Migration[7.1]
  def change
    create_table :albums do |t|
      t.string :name

      t.timestamps
    end
    add_index :albums, :name, unique: true
  end
end
