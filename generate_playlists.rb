require './db/setup'
require './lib/all'

letters = ('a'..'z').to_a

letters.each do |l|
  Playlist.create(name: l)
end

Playlist.create(name: "top_playlist")

Song.find_each do |s|
  Playlist.add s
end
