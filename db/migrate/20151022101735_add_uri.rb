class AddUri < ActiveRecord::Migration
  def change
    change_table :songs do |t|
      t.string :uri
  end
end
