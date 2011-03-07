###################################################################################################
#
# Rake: maintenance
# This task runs various maintenance tasks once per day
#
###################################################################################################

namespace :maintenance do
  
  desc "Reindex Podcasts"
  task :reindex_podcasts => :environment do
    Rake::Task['sunspot:reindex'].invoke
    sleep 3
  end  
  
  desc "Stop Sunspot"
  task :stop_sunspot => :reindex_podcasts do
    Rake::Task['sunspot:solr:stop'].invoke
    sleep 3
  end
  
  desc "Start Sunspot"
  task :start_sunspot => :stop_sunspot do
    Rake::Task['sunspot:solr:start'].invoke
    sleep 3
  end
  
  desc "Generate Documentation"
  task :generate_docs => :start_sunspot do
    Rake::Task['doc:app'].invoke
    sleep 3
  end
  
  desc "Restart Server"
  task :restart_server => :generate_docs do
    `touch tmp/restart.txt`
    sleep 3
  end
  
  desc "Maintain Log Directories"
  task :maintain_log_dir => :restart_server do
    Mention.maintain_log_dir
  end
  
  desc "Daily Maintenance"
  task :daily => :maintain_log_dir do
    Rake::Task['initialize:all'].invoke
  end
  
end