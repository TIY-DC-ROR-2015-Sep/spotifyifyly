class User < ActiveRecord::Base
  validates_presence_of :email, :password
  validates_uniqueness_of :email

  def songs_vetoed
    vetoes = Vetoes.where( user_id: id )
    vetoes.map { |v| v.song }
  end
end
