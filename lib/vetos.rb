class Veto < ActiveRecord::Base
  validates_presence_of :user_id
  validates_uniquness_of :user_id
end
