class Song < ActiveRecord::Base
  validates_presence_of :title, :suggested_by

  has_many :votes
  has_many :playlist_songs
  has_many :playlists, through: :playlist_songs
  belongs_to :suggested_by, class_name: "User"

  def vetoed?
    # TODO: Within this week.
    Veto.where(song_id: self.id).count > 0
  end

end
