class CreatePodcasts < ActiveRecord::Migration
  def self.up
    create_table :podcasts do |t|
      t.string :name
      t.string :url
      t.string :streamurl
      t.string :category
      t.string :host
      t.string :twitter
      t.string :facebook
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :podcasts
  end
end
