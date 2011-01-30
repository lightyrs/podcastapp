class AddIndexToPodcasts < ActiveRecord::Migration
  def self.up
    add_index :podcasts, :name, :unique => true
  end

  def self.down
    remove_index :podcasts, :name
  end
end
