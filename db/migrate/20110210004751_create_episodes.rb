class CreateEpisodes < ActiveRecord::Migration
  def self.up
    create_table :episodes do |t|
      t.string :title
      t.text :shownotes
      t.string :url
      t.string :filename
      t.string :filetype
      t.string :size
      t.string :duration

      t.timestamps
    end
  end

  def self.down
    drop_table :episodes
  end
end
