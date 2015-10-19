require "./db/setup"
require "./lib/all"

require "./song_search.rb"

Search.find_song_spotify "stay with me"
binding.pry
