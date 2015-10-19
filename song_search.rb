require 'httparty'
class Search
  attr_reader :title, :album_name, :album_image, :preview_url, :artist


  def self.find_song_spotify song

    s = song.gsub(/\s/,'+')
    key = File.read "./api.txt"
    r = HTTParty.get "https://api.spotify.com/v1/search?q=#{s}&type=track",
    headers:{"Authorization" => "Bearer #{key}"}
    r["tracks"]["items"].each do |song|

      @title = song["name"]
      @album_name =  song["album"]["name"]
      @album_image = song["album"]["images"][1]
      @artist = song["artists"][0]["name"]
      @preview_url = song["preview_url"]
      binding.pry
    end
  end
  puts "#{@title}, by #{@artist}"
end
