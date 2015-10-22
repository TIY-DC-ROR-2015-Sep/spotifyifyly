require 'httparty'
class Search
  attr_reader :title, :album_name, :album_image, :preview_url, :artist


  def self.find_song_spotify song

    s = song.gsub(/\s/,'+').gsub(/'/,"%27")
    key = ENV["SPOTIFY_KEY"] || File.read("./api.txt")
    r = HTTParty.get "https://api.spotify.com/v1/search?q=#{s}&type=track",
    headers:{"Authorization" => "Bearer #{key}"}
    song_dets = []
    r["tracks"]["items"].first(5).each do |song|
      finds = {
          :title => song["name"],
          :album_name =>  song["album"]["name"],
          :album_image => song["album"]["images"],
          :artist => song["artists"][0]["name"],
          :preview_url => song["preview_url"]
      }
      song_dets.push(finds)
    end
    song_dets
  end

  def self.create_playlist_spotify
    r = HTTParty.post "https://api.spotify.com//v1/users/spotsfyifyly/playlists",
    headers:{
      "Accept" => "application/json",
      "Authorization" => "Bearer #{key}",
      "Content-Type:" => "application/json"
    },
      body: {
    name: "This week's playlist",
    public: true
      }.to_json
  end

  def self.add_songs_to_playlist_spotify song
  end

  def self.remove_songs_from_spotify song
    r = HTTParty.post ""
  end

end
