require 'sinatra/base'
require 'pry'

require './db/setup'
require './lib/all'


class Spotifyifyly < Sinatra::Base
  enable :sessions

  set :logging, true

  def current_user
    # If you're logged in, return logged in User
    # If not logged in, return nil
    logged_in_user_id = session[:logged_in_user_id]
    User.find_by_id(logged_in_user_id)
  end

  get "/" do
    if current_user
      "You are #{current_user.email}"
    else
      "It works!"
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

get "/suggest_song/" do
  if current_user
  erb :addition2main
 else
   "Please login to suggest a song"
   erb :login
end
end

  post "/suggest_song/" do
    s = params[:suggested_song].to_s
    #find_song_spotify s
    Song.create( title: s, suggested_by: current_user.id)
    erb :addition2main
  end

end

Spotifyifyly.run!
