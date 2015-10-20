class User < ActiveRecord::Base
  validates_presence_of :email, :password
  validates_uniqueness_of :email

  def songs_voted_for
    votes = Vote.where( user_id: id )
    votes.map { |v| v.song } 
  end
end
