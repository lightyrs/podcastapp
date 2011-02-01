class AddItunesRatingCountToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :itunes_rating_count, :integer
  end

  def self.down
    remove_column :podcasts, :itunes_rating_count
  end
end
