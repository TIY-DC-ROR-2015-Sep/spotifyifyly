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
    User.find(10)
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
    else
      # error message
      erb :login
    end
  end

end

Spotifyifyly.run!
