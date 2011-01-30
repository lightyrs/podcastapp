class AddSiteurlColumnToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :siteurl, :string
  end

  def self.down
    remove_column :podcasts, :siteurl
  end
end
