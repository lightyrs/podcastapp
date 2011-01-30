class RenameUrlColumnToItunesurl < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :url, :itunesurl
  end

  def self.down
    rename_column :podcasts, :itunesurl, :url
  end
end
