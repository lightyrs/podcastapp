class AddUniqueIndexToEpisodeTitle < ActiveRecord::Migration
  def self.up
    add_index :episodes, :title, :unique => true
  end

  def self.down
    remove_index :episodes, :title
  end
end