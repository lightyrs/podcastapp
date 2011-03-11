###################################################################################################
#
# Rake: initialize
# This task starts all processes required by podcastapp
#
###################################################################################################

namespace :initialize do
  
  desc "Start Sunspot"
  task :start_sunspot => :environment do
    begin
      Thread.new do
        Rake::Task['sunspot:solr:start'].invoke
      end
      sleep 3
    rescue Sunspot::Server::AlreadyRunningError
      puts "Sunspot is already running!"
    end
  end  

  desc "Start Delayed Job"
  task :start_delayed_job => :start_sunspot do
    begin
      `ruby script/delayed_job start`
    rescue => ex
      puts "#{ex.class}"
    end
  end
  
  desc "Start Twitter Daemon"
  task :start_twitter_daemon => :start_delayed_job do
    begin
      Rake::Task['mentions:twitter'].invoke
    rescue => ex
      puts "#{ex.class}"
    end
  end
  
  desc "Start Facebook Daemon"
  task :start_facebook_daemon => :start_twitter_daemon do
    begin
      Rake::Task['mentions:facebook'].invoke
    rescue => ex
      puts "#{ex.class}"
    end
  end

  desc "Initialize All"
  task :all => :start_facebook_daemon do
    puts "All Dependencies Initialized"
  end
  
end