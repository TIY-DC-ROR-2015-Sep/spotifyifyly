require 'httparty'

class SpotifyApi
  attr_reader :key

  #ClientId     = "9664357146fe44a5a9c0c1247f623e76"
#  ClientSecret = ENV["SPOTIFY_SECRET_KEY"]    || File.read("spotify_secret.txt").chomp
#  RefreshToken = ENV["SPOTIFY_REFRESH_TOKEN"] || File.read("spotify_refresh.txt").chomp

  def initialize
    @key = "BQDPrt7aYM_u8DdZrjnZRLlqF0nBnTy0O4eKMZ7nEMk9IMWlve5Peq17yRx-bZMf8o5FfzW9ogqQE_fiBznO8DOzoLfwjv1taFwaRJ4isAayu1qtdOFQr6tdoXY_HmuhnNjqoxfTEAs0IHc1o0kwLHICbqTREisV96YChEUhof4H13m3pL7Rws1Wgo25XFCjIZiYl4hAkRB5d4UL7Y8Z7ZnQJQmCbgbJq2D2qGcNetdxnqW0wDepL8z-3lg"||nil
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

     #refresh_if_needed do
    r =  HTTParty.get "https://api.spotify.com/v1/search?q=#{s}&type=track",
      headers:{"Authorization" => "Bearer #{key}"}
  #  end

    song_dets = []
    r["tracks"]["items"].first(5).each do |song|
      finds = {
        :title => song["name"],
        :album_name =>  song["album"]["name"],
        :album_image => song["album"]["images"][2],
        :artist => song["artists"][0]["name"],
        :preview_url => song["preview_url"],
        :uri => song["uri"]
      }
      song_dets.push(finds)
    end
    song_dets
  end


  def create_playlist_spotify
     #refresh_if_needed do
    r =  HTTParty.post "https://api.spotify.com/v1/users/sophiapeaslee/playlists",
      headers:{
        "Accept" => "application/json",
        "Authorization" => "Bearer #{key}",
        "Content-Type:" => "application/json"
      },
      body: {
        name: "This week's playlist",
        public: true
      }.to_json
    #end

    pl_info = {
      :pl_id => r["id"],
      :pl_name => r["name"],
      :pl_uri => r["uri"]
    }

     playlist = Playlist.find_by_name("top_playlist")
     playlist.update(plid: pl_info[:pl_id])
  end

  def pull_playlist pl_id
    id = pl_id
    #r = refresh_if_needed do # this finds the position of the song to be deleted
    r = HTTParty.get "https://api.spotify.com/v1/users/sophiapeaslee/playlists/#{id}/tracks",
      headers:{"Authorization" => "Bearer #{key}"}

  #  end
    song_dets = []
    r["items"].each do |song|
      finds = {
        :title => song["name"],
        :uri => song["uri"]
      }
      song_dets.push(finds)
    end
    song_dets
  end

  def add_songs_to_playlist_spotify song_uri
    id = Playlist.find_by_name("top_playlist").plid
    song = song_uri
    if song
      m = song.gsub(/:/,"%3A") #converts : so it is searchable here
      song_dets = pull_playlist id #do this here to prevent pushing duplicate songs to the playlist
      binding.pry
        if !song_dets.any? { |det| det[:uri] == song }
          #r = refresh_if_needed do

          r = HTTParty.post "https://api.spotify.com/v1/users/sophiapeaslee/playlists/#{id}/tracks?position=0&uris=#{m}",
            headers:{
              "Accept" => "application/json",
              "Authorization" => "Bearer #{key}"
            }
          end
        #end
      end
    end

    def remove_songs_from_spotify song #need to figure out how to pass in name to be deleted
      id = Playlist.find_by_name("top_playlist").plid
      s = song.title
      pull_playlist id
        position = song_dets.index(title: "#{s}")

      r= HTTParty.delete "https://api.spotify.com/v1/users/spotifyifyly/playlists/#{id}/tracks",
      headers:{
        "Accept" => "application/json",
        "Authorization" => "Bearer #{key}",
        "Content-Type:" => "application/json"
      },
      body: {
        tracks: [
          positions: position,
          uri: song_dets[position][:uri] #dont need to convert because passed in body
        ]}.to_json
      end

end
