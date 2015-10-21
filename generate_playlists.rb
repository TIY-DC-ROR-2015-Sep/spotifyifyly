require './db/setup'
require './lib/all'

class GeneratePlaylists
  letters = ('a'..'z').to_a

  letters.each do |l|
    Playlist.create(name: l)
  end

  Playlist.create(name: "top_playlist")
end

GeneratePlaylists.new
