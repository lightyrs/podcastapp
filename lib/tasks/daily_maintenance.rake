###################################################################################################
#
# Rake: maintenance
# This task runs all of the various scraping methods in the Podcast class
#
###################################################################################################

namespace :maintenance do
  
  desc "Stop Sunspot"
  task :stop_sunspot => :environment do
    Rake::Task['sunspot:solr:stop'].invoke
  end
  
  desc "Start Sunspot"
  task :start_sunspot => :stop_sunspot do
    Rake::Task['sunspot:solr:start'].invoke
  end
  
  desc "Daily Maintenance"
  task :daily => :start_sunspot do
    # Invoke the daily maintenance tasks
  end
  
end