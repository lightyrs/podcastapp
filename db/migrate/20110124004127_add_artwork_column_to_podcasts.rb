class AddArtworkColumnToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :artwork, :string
  end

  def self.down
    remove_column :podcasts, :artwork
  end
end
