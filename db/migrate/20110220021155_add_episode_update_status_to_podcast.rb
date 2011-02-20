class AddEpisodeUpdateStatusToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :episode_update_status, :string
  end

  def self.down
    remove_column :podcasts, :episode_update_status
  end
end
