class AddUniqueIndexToEpisodeTitleWithScope < ActiveRecord::Migration
  def self.up
    add_index :episodes, [:title, :podcast_id], :unique => true
  end

  def self.down
    remove_index :episodes, :title
  end
end
