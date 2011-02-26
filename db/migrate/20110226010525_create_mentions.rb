class CreateMentions < ActiveRecord::Migration
  def self.up
    create_table :mentions do |t|
      t.text :mention
      t.string :network
      t.string :username
      t.string :avatar
      t.float :sentiment
      t.float :reputation

      t.timestamps
    end
  end

  def self.down
    drop_table :mentions
  end
end
