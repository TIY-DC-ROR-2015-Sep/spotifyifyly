require 'sinatra/base'
require 'pry'

require './db/setup'
require './lib/all'
require './song_search.rb'

class Spotifyifyly < Sinatra::Base
  enable :sessions

  set :logging, true
  set :session_secret, "my_secret_key_thats_really_secret_i_*swear*"

  def current_user
    # If you're logged in, return logged in User
    # If not logged in, return nil
    logged_in_user_id = session[:logged_in_user_id]
    User.find_by_id(logged_in_user_id)
  end

  get "/" do
    if current_user
      #"You are #{current_user.email}"
      erb :index
    else
      #"It works!"
      erb :homepage
    end
  end

  get "/login" do
    erb :login
  end

  post "/handle_login" do
    found = User.where(
      email:    params[:email],
      password: params[:password]
    ).first

    if found
      session[:logged_in_user_id] = found.id
      redirect to("/")
    else
      # Show the form again
      @error = "Invalid username or password"
      erb :login
    end
  end

  post "/vote" do
    if current_user
      v = Vote.new
      v.user_id = current_user.id
      v.song_id = params[:song_id].to_i

      if v.vote_check_passed
        v.save!
      else
        # error message
      end
      redirect to("/")
    else
      # error message
      erb :login
    end
  end

  get "/profile" do
    if current_user
      @user_songs = current_user.user_songs
      erb :profile
    else
      redirect to("/login")
    end
  end

  get "/suggest_song" do
    if current_user
      erb :addition2main, locals:{ results: nil}
    else
      "Please login to suggest a song"
      erb :login
    end
  end

  post "/suggest_song" do
    if current_user
      s = params[:suggested_song].to_s
      m = Search.find_song_spotify s
      erb :result_page, locals:{ results: m}
    else
      redirect to "/login"
    end
  end

  post "/save_song" do
    j = params[:result]
    t = JSON.parse(j)
    Song.create( title: t["title"], suggested_by: current_user, artist: t["artist"], spotify_preview_url: t["preview_url"], album_name: t["album_name"], album_image: t["album_image"])
    erb :addition2main
  end
end

Spotifyifyly.run!
