class Song < ActiveRecord::Base
  validates_presence_of :title, :suggested_by

  has_many :votes
  has_many :users_who_voted_for, through: :votes, source: :user

  has_many :playlist_songs
  has_many :playlists, through: :playlist_songs

  belongs_to :suggested_by, class_name: "User"

  def vetoed?
    # TODO: Within this week.
    Veto.where(song_id: self.id).count > 0
  end

  # def users_who_voted_for
  #   # n+1 queries
  #   # users = []
  #   # votes.each do |vote|
  #   #   users.push vote.user
  #   # end
  #   # users
  #
  #   # 2 queries
  #   user_ids = votes.pluck(:user_id)
  #   User.where(id: user_ids)
  # end

end
