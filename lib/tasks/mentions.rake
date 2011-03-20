###################################################################################################
#
# Rake: mentions
# This task processes all data from realtime social apis.
#
###################################################################################################

namespace :mentions do
  
  desc "Start twitter daemon"
  task :twitter => :environment do
    `ruby script/twitter start`
  end
  
  desc "Start facebook daemon"
  task :facebook => :environment do
    `ruby script/facebook_daemon start`
  end
  
end