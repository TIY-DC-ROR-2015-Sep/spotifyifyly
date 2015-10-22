require 'httparty'

class SpotifyApi
  attr_reader :key

  ClientId     = "9664357146fe44a5a9c0c1247f623e76"
  ClientSecret = ENV["SPOTIFY_SECRET_KEY"]    || File.read("spotify_secret.txt").chomp
  RefreshToken = ENV["SPOTIFY_REFRESH_TOKEN"] || File.read("spotify_refresh.txt").chomp

  def initialize
    @key = nil
  end

  def refresh_key
    puts "~~> Refreshing Spotify key <~~"
    encoded  = Base64.strict_encode64 "#{ClientId}:#{ClientSecret}"
    response = HTTParty.post "https://accounts.spotify.com/api/token",
        query: {
          grant_type: "refresh_token",
          refresh_token: RefreshToken
        },
        headers: {
          "Authorization" => "Basic #{encoded}"
        }

    unless response.code == 200
      raise "Failed to get refreshed token: #{response}"
    end

    @key = response["access_token"]
  end

  def refresh_if_needed
    response = yield
    if response.code >= 400 && response.code < 500
      puts "Response errored: #{response}"
      refresh_key
      response = yield
    end
    response
  end

  def find_song_spotify song
    s = song.gsub(/\s/,'+').gsub(/'/,"%27")

    r = refresh_if_needed do
      HTTParty.get "https://api.spotify.com/v1/search?q=#{s}&type=track",
                     headers:{"Authorization" => "Bearer #{key}"}
    end

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
