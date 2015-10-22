class Vote < ActiveRecord::Base
  validates_presence_of :user_id, :song_id

  belongs_to :user
  belongs_to :song

  def vote_check_passed
    user.votes.count < 10
  end
end
