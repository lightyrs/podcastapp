class AddDatePublishedToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :date_published, :string
  end

  def self.down
    remove_column :episodes, :date_published
  end
end
