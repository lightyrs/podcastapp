class RemoveFileNameFromEpisodes < ActiveRecord::Migration
  def self.up
    remove_column :episodes, :filename
  end

  def self.down
    add_column :episodes, :filename, :string
  end
end
