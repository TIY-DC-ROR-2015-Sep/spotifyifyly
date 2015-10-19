class User < ActiveRecord::Base
  validates_presence_of :email, :password
  validates_uniqueness_of :email

  def user_songs

  end
end
