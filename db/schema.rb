# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110210005056) do

  create_table "episodes", :force => true do |t|
    t.string   "title"
    t.text     "shownotes"
    t.string   "url"
    t.string   "filename"
    t.string   "filetype"
    t.string   "size"
    t.string   "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "podcast_id"
    t.string   "date_published"
  end

  add_index "episodes", ["title"], :name => "index_episodes_on_title", :unique => true

  create_table "podcasts", :force => true do |t|
    t.string   "name"
    t.string   "itunesurl"
    t.string   "feedurl"
    t.string   "category"
    t.string   "hosts"
    t.string   "twitter"
    t.string   "facebook"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "artwork"
    t.string   "siteurl"
  end

  add_index "podcasts", ["name"], :name => "index_podcasts_on_name", :unique => true

end
