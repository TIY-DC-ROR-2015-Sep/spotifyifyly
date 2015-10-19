require './db/setup'
require './lib/all'

require 'pry'

class DisplaySongs

  def song_information
    Song.find_each do |song|
      {
        title: song.title,
        artist: song.artist,
        genre: song.genre,
        preview: song.spotify_preview_url,
        user: song.submitted_by_id
      }
    end
  end
end
