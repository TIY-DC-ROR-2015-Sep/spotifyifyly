require 'httparty'
class Search
  attr_reader :title, :album_name, :album_image, :preview_url, :artist


  def self.find_song_spotify song

    s = song.gsub(/\s/,'+').gsub(/'/,"%27")
    key = File.read "./api.txt"
    r = HTTParty.get "https://api.spotify.com/v1/search?q=#{s}&type=track",
    headers:{"Authorization" => "Bearer #{key}"}
    song_dets = []
    r["tracks"]["items"].first(5).each do |song|
      finds = {
          :title => song["name"],
          :album_name =>  song["album"]["name"],
          :album_image => song["album"]["images"][2],
          :artist => song["artists"][0]["name"],
          :preview_url => song["preview_url"]
      }
      song_dets.push(finds)
    end
    song_dets
  end
end
