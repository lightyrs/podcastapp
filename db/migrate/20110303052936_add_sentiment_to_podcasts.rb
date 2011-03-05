class AddSentimentToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :sentiment, :float
  end

  def self.down
    remove_column :podcasts, :sentiment
  end
end
