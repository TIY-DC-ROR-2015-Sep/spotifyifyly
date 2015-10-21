class Song < ActiveRecord::Base
  validates_presence_of :title, :suggested_by

  belongs_to :suggested_by, class_name: "User"

  def vetoed
    #Within the same week
    
  end

end
