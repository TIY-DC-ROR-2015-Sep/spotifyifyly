require 'sinatra/base'
require 'pry'
require 'gravatarify'
require 'rollbar/middleware/sinatra'

require './db/setup'
require './lib/all'


Search = SpotifyApi.new
Search.refresh_key if Search.key.nil?

Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
end if ENV["ROLLBAR_ACCESS_TOKEN"]


class Spotifyifyly < Sinatra::Base
  helpers Gravatarify::Helper
  enable :sessions
  enable :method_override

  set :logging, true
  set :session_secret, (ENV["SESSION_SECRET"] || "this_isnt_really_secret_but_its_only_for_development_so_thats_okay")

  use Rollbar::Middleware::Sinatra

  if ENV["PORT"]
    set :port, ENV["PORT"]
  end

  def current_user
    # If you're logged in, return logged in User
    # If not logged in, return nil
    logged_in_user_id = session[:logged_in_user_id]
    @current_user ||= User.find_by_id(logged_in_user_id)
  end

  def admin_user
    current_user && current_user.admin?
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

  def erb_for_user template_name
    if current_user && current_user.wants_retro_layout?
      erb template_name, layout: :retro_layout
    else
      erb template_name
    end
  end

  def get_digested message
    Digest::SHA256.hexdigest message
  end

  get "/" do
    Playlist.top_playlist
    erb_for_user :index
  end

  get "/retro" do
    erb :retro_layout
  end

  get "/about" do
    erb :about
  end

  get "/login" do
    erb_for_user :login
  end

  post "/handle_login" do
    found = User.where(
      email:    params[:email],
      password: (get_digested params[:password])
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
    temp_password = ('a'..'z').to_a.shuffle[0,8].join 
    @new_user = User.new
    @new_user.name = params[:name]
    @new_user.email = params[:email]
    email = Email.new @new_user, temp_password
    email.invite_user_mail
    @new_user.password = get_digested temp_password
    if @new_user.save
      set_message "User has been created"
      redirect to("/invite")
    else
      erb :invite
    end
  end

  get "/invite" do
    admin_required!
    @new_user = User.new
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
    s = Song.create( title: t["title"], suggested_by: current_user, artist: t["artist"], spotify_preview_url: t["preview_url"], album_name: t["album_name"], album_image: t["album_image"], uri: t["uri"])

    if Playlist.add s
      Vote.create! user_id: current_user.id, song_id: s.id
      set_message "Your song was added to the playlist!"
    else
      set_message "Your song is already on a playlist!"
    end
    redirect to("/")
  end

  get "/change_password" do
    login_required!
    erb :change_password
  end

  post "/change_password" do
    login_required!
    if ( get_digested params[:oldpass] ) != current_user.password
      set_message "Your old password was entered incorrectly"
      redirect to "/change_password"
    elsif ( params[:newpass] != params[:newpass2] ) || ( params[:newpass].length < 6 )
      set_message "Your passwords must match and be more than 6 characters"
      redirect to "/change_password"
    else
      current_user.update! password: (get_digested params[:newpass])
      set_message "Your password was changed"
      redirect to "/profile"
    end
  end

  get "/playlists" do
    login_required!
    Search.refresh_if_needed do
      1 / 0
    end
    "Ok"
  end
end


if $PROGRAM_NAME == __FILE__
  Spotifyifyly.run!
end
