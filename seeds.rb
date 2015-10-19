require './db/setup'
require './lib/all'

User.delete_all
Song.delete_all

names = ['andrew', 'devin', 'justin', 'sophia', 'jamaal']

names.each do |name|
  User.create! email: "#{name}@example.com", password: "hunter2", name: name
end

songs = [{
  title: "The Hills",
  artist: "The Weeknd"},
  {
  title: "Hotline Bling",
  artist: "Drake"},
  {
  title: "What Do You Mean?",
  artist: "Justin Bieber"},
  {
  title: "Watch Me",
  artist: "Silento"},
  {
  title: "Can't Feel My Face",
  artist: "The Weeknd"},
  {
  title: "Locked Away",
  artist: "R. City Featuring Adam Levine"}
  ]

songs.each do |song|
  Song.create! title: song[:title], artist: song[:artist], suggested_by: User.all.sample 
end
