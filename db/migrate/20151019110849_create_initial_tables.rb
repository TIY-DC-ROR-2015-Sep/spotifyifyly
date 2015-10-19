class CreateInitialTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :password
    end

    create_table :songs do |t|
      t.integer :suggested_by_id
      t.string  :title
      t.string  :artist
      t.string  :genre
      t.string  :spotify_preview_url
    end

    create_table :playlists do |t|
      t.datetime :created_at
    end

    create_table :votes do |t|
      t.integer  :user_id
      t.integer  :song_id
      t.datetime :created_at
    end

    create_table :vetos do |t|
      t.integer  :user_id
      t.integer  :song_id
      t.datetime :created_at
    end

    create_table :playlist_songs do |t|
      t.integer :playlist_id
      t.integer :song_id
    end
  end
end
