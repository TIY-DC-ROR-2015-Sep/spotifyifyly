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

  get "/vote" do
    binding.pry
    #user_id = session[:logged_in_user_id]
    #song_name ==> from params ==> find id

    #Vote.create! user_id: current_user.id, song_id:




  end

  post "/veto" do
    if current_user
      ve = Veto.new
      ve.user_id = current_user.id
      ve.song_id = params[:song_id].to_i

      if ve.veto_available
        ve.save!
      else
        #No more vetoes available this week.
      end
    else
      redirect_to "/login"    
    end
  end











end

Spotifyifyly.run!
