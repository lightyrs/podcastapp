class AddPodcastIdToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :podcast_id, :integer
  end

  def self.down
    remove_column :episodes, :podcast_id
  end
end
