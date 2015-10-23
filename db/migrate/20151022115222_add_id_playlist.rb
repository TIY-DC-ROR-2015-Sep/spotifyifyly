class AddIdPlaylist < ActiveRecord::Migration
  def change
    change_table :playlists do |t|
      t.string :plid
    end
  end
end
