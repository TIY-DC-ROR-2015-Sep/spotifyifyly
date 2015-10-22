require './db/setup'
require './lib/all'

User.all.each do |u|
  current_password = u.password
  u.update! password: Digest::SHA256.hexdigest(current_password) 
end
