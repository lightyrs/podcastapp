# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
#
# Learn more: http://github.com/javan/whenever

# Set environment to development
set :environment, "development"

# Run daily maintenance cron every night
every 1.day, :at => '11:00 pm' do
  rake 'maintenance:daily &> /dev/null'
end

# Scrape podcasts but only update new podcasts (and don't send local mail)
every [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday], :at => '12:30 am' do
  rake 'podcast:generate_inventory["new"] &> /dev/null'
end

# Scrape and update all podcasts (and don't send local mail)
every :sunday, :at => '12:30 am' do
  rake "podcast:generate_inventory &> /dev/null" 
end