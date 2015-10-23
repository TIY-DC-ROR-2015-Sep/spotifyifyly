require 'minitest/autorun'
require 'rack/test'
require 'pry'
require 'capybara'
require 'capybara/dsl'

ENV["TEST"] = "true"
require './app'

Capybara.app = Spotifyifyly

class SpotTest < Minitest::Test
  include Capybara::DSL

  def setup
    User.delete_all
    Playlist.delete_all
    Song.delete_all

    letters = ('a'..'z').to_a

    letters.each do |l|
      Playlist.create(name: l)
    end

    Playlist.create(name: "top_playlist")

    Song.find_each do |s|
      Playlist.add s
    end
  end

  def test_can_vote_for_songs
    u = User.create! name: "tester", email: "test@example.com", password: "hunter2"
    # or POST /save_song with data ...
    Playlist.add(Song.create! title: "A1", suggested_by: u)
    Playlist.add(Song.create! title: "A2", suggested_by: u)

    # User logs in
    visit "/login"
    within ".login-page" do
      fill_in "email", with: "test@example.com"
      fill_in "password", with: "hunter2"
      click_on "Login"
    end

    assert_equal "/", current_path
    assert page.has_content? "Logout"
    assert page.has_content? "tester"

    # User votes on a song
    binding.pry
  end
end
