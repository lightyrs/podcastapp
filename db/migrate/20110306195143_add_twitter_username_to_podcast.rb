class AddTwitterUsernameToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :twitter_handle, :string
  end

  def self.down
    remove_column :podcasts, :twitter_handle
  end
end
