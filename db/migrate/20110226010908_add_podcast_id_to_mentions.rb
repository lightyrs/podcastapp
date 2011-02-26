class AddPodcastIdToMentions < ActiveRecord::Migration
  def self.up
    add_column :mentions, :podcast_id, :integer
  end

  def self.down
    remove_column :mentions, :podcast_id
  end
end
