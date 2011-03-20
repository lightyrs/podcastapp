class RemoveSentimentFromPodcast < ActiveRecord::Migration
  def self.up
    remove_column :podcasts, :sentiment
  end

  def self.down
    add_column :podcasts, :sentiment, :float
  end
end
