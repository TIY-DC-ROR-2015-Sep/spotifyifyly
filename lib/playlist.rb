class Playlist < ActiveRecord::Base
  validates_uniqueness_of :name
  has_many :songs, through: :playlist_song

  def self.add song
    p = Playlist.find_by_name(song.title[0].downcase)

    unless p.include?(song)
      PlaylistSong.new( playlist_id: p.id, song_id: song.id ).save
    end
  end

  def self.sort_by_votes
    songs.each do |s|
      s.votes.count
    end
  end

  def top_playlist
    top_playlist = Playlist.find_by_name("top_playlist")
    top_playlist.delete_all

    Playlist.all.each do |pl|
      list = pl.sort_by { |s| s.votes.count }
      if list
        PlaylistSong.new( playlist_id: top_playlist.id, song_id: list.first.id )
      end
    end
  end
end
