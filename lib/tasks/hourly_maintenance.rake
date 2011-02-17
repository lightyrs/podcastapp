###################################################################################################
#
# Rake: maintenance
# This task runs various maintenance tasks once per hour
#
###################################################################################################

namespace :maintenance do
  
  desc "Stop Sunspot"
  task :restart_server => :environment do
    puts `touch tmp/restart.txt`
  end
  
  desc "Hourly Maintenance"
  task :hourly => :restart_server do
    # Invoke the hourly maintenance tasks
    puts `touch tmp/restart.txt`
  end
  
end