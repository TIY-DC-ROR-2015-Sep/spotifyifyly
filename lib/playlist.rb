class Playlist < ActiveRecord::Base
  validates_uniqueness_of :name

  has_many :playlist_songs
  has_many :songs, through: :playlist_songs

  def self.add song
    p = Playlist.find_by_name(song.title[0].downcase)

    unless p.songs.include? song
      PlaylistSong.new( playlist_id: p.id, song_id: song.id ).save
    end
  end

  def self.top_playlist
    top_playlist = Playlist.find_by_name("top_playlist")
    top_playlist.songs.delete_all

    Playlist.all.each do |pl|
      next if pl == top_playlist
      big_list = pl.songs.sort_by { |s| s.votes.count }.reverse
      list = big_list.reject { |s| s.vetoed? }
      songs_to_delete = big_list - list
        songs_to_delete.each do |song|
          SpotifyApi.new.remove_songs_from_spotify song
        end
      if list.any?
        PlaylistSong.create( playlist_id: top_playlist.id, song_id: list.first.id )
        SpotifyApi.new.add_songs_to_playlist_spotify list.first.uri
      end
    end
  end
end
