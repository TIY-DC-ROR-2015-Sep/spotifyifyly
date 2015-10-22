require 'sinatra/base'
require 'pry'

require './db/setup'
require './lib/all'

Search = SpotifyApi.new
Search.refresh_key if Search.key.nil?

class Spotifyifyly < Sinatra::Base
  enable :sessions
  enable :method_override

  set :logging, true
  set :session_secret, (ENV["SESSION_SECRET"] || "this_isnt_really_secret_but_its_only_for_development_so_thats_okay")

  if ENV["PORT"]
    set :port, ENV["PORT"]
  end

  def current_user
    # If you're logged in, return logged in User
    # If not logged in, return nil
    logged_in_user_id = session[:logged_in_user_id]
    User.find_by_id(logged_in_user_id)
  end

  def admin_user
    current_user_id = session[:logged_in_user_id]
    User.find_by_id(current_user_id).admin?
  end

  def set_message text
    session[:message] = text
  end

  def read_and_reset_message
    #val = session[:message]
    session.delete :message
    #return val
  end

  def login_required!
    unless current_user
      set_message "You must login to view this page"
      redirect to("/login")
    end
  end

  def admin_required!
    login_required!
    unless admin_user
      set_message "Only administrators may invite new members"
      redirect to("/login")
    end
  end

  get "/" do
    Playlist.top_playlist
    erb :index
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

  delete "/logout" do
    session.delete :logged_in_user_id
    set_message "You are now logged out"
    redirect to("/")
  end

  post "/invite" do
    admin_required!
    u = User.new
    u.name = params[:name]
    u.email = params[:email]
    u.password = params[:password]
    if u.save
      set_message "User has been created"
    else
      set_message "Email is already in use"
    end
    redirect to("/invite")
  end

  get "/invite" do
    admin_required!
    erb :invite
  end

  post "/vote" do
    login_required!
    v = Vote.new
    v.user_id = current_user.id
    v.song_id = params[:song_id].to_i

    if v.vote_check_passed
      v.save!
    else
      # error message
    end
    redirect to("/")
  end

  post "/veto" do
    login_required!

    ve = Veto.new
    ve.user_id = current_user.id
    ve.song_id = params[:song_id].to_i

    if ve.veto_available && ve.save
      set_message "Your veto has been recorded"
    else
      set_message "No more vetos available this week"
    end

    redirect to("/")
  end

  get "/profile" do
    login_required!
    @user_songs = current_user.user_songs
    erb :profile
  end

  # TODO: remove this?
  get "/suggest_song" do
    if current_user
      erb :addition2main, locals:{ results: nil}
    else
      "Please login to suggest a song"
      erb :login
    end
  end

  post "/suggest_song" do
    login_required!
    s = params[:suggested_song].to_s
    m = Search.find_song_spotify s
    erb :result_page, locals:{ results: m}
  end

  post "/save_song" do
    login_required!
    j = params[:result]
    t = JSON.parse(j)
    s = Song.create( title: t["title"], suggested_by: current_user, artist: t["artist"], spotify_preview_url: t["preview_url"], album_name: t["album_name"], album_image: t["album_image"])

    if Playlist.add s
      set_message "Your song was added to the playlist!"
    else
      set_message "Your song is already on a playlist!"
    end
    redirect to("/")
  end

end

Spotifyifyly.run!
