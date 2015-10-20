class Vote < ActiveRecord::Base
  validates_presence_of :user_id, :song_id

  belongs_to :user
  belongs_to :song

  def vote_check_passed
     # any?.. all?
    user.songs_voted_for.each do |s|
      if s.title[0] == song.title[0]
        return false
      end
    end
    return true
  end
end
