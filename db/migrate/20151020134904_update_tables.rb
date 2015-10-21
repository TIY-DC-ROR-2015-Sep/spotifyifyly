class UpdateTables < ActiveRecord::Migration
  def change
    change_table :songs do |t|
      t.string  :album_name
      t.string  :album_image
    end
  end
end
