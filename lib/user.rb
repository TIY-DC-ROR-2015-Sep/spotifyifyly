class User < ActiveRecord::Base
  validates_presence_of :name, :email, :password
  validates_uniqueness_of :email

  def songs_vetoed
    vetoes = Veto.where( user_id: id )
    vetoes.map { |v| v.song }
  end

  def songs_voted_for
    votes = Vote.where( user_id: id )
    votes.map { |v| v.song }
  end

  def user_songs
    user_song_arr = []
    Song.all.each do |song|
      if song.suggested_by_id == self.id
        user_song_arr << song
      end
    end
    user_song_arr
  end
end
