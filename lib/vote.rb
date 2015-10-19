class Vote < ActiveRecord::Base
  validates_presence_of :user_id, :song_id
end
