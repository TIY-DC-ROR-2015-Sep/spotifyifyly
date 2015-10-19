require 'httparty'
class Search
attr_reader :song

def initalize data_hash
  @title = data_hash["name"]
  @artist = data_hash["artists"]
  @album = data_hash["album"]
  @preview_url = data_hash["preview_url"]

end

def find_song_spotify song
  s = song.gsub(/\s/,'+')
  r = HTTParty.get("https://api.spotify.com/v1/search?q=#{s}&type=track")
  r["tracks"].map {h Search.new(h)}
  "#{h["name"]}"
end

def results



end
