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

ActiveRecord::Schema.define(:version => 20110320065025) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "episodes", :force => true do |t|
    t.string   "title"
    t.text     "shownotes"
    t.string   "url"
    t.string   "filetype"
    t.string   "size"
    t.string   "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "podcast_id"
    t.string   "date_published"
  end

  add_index "episodes", ["title", "podcast_id"], :name => "index_episodes_on_title_and_podcast_id", :unique => true

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
    t.string   "episode_update_status"
    t.string   "twitter_handle"
  end

  add_index "podcasts", ["name"], :name => "index_podcasts_on_name", :unique => true

end
