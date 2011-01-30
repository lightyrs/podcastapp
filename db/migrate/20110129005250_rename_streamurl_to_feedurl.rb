class RenameStreamurlToFeedurl < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :streamurl, :feedurl
  end

  def self.down
    rename_column :podcasts, :feedurl, :streamurl
  end
end
