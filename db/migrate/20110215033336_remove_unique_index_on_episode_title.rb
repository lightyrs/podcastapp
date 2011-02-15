class RemoveUniqueIndexOnEpisodeTitle < ActiveRecord::Migration
  def self.up
    remove_index :episodes, :title 
  end

  def self.down
    add_index :episodes, :title, :unique => true
  end
end
