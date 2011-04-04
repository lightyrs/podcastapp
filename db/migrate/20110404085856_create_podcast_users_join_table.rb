class CreatePodcastUsersJoinTable < ActiveRecord::Migration
  def self.up
    create_table :podcasts_users, :id => false do |t|
      t.integer :podcast_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :podcasts_users
  end
end
