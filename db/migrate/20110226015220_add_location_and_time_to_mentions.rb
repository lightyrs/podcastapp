class AddLocationAndTimeToMentions < ActiveRecord::Migration
  def self.up
    add_column :mentions, :location, :string
    add_column :mentions, :date_and_time, :datetime
  end

  def self.down
    remove_column :mentions, :location
    remove_column :mentions, :date_and_time
  end
end
