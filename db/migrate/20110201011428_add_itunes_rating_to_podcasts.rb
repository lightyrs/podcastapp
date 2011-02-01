class AddItunesRatingToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :itunes_rating, :string
  end

  def self.down
    remove_column :podcasts, :itunes_rating
  end
end
