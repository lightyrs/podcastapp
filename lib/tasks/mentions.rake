###################################################################################################
#
# Rake: mentions
# This task processes all data from realtime social apis.
#
###################################################################################################

namespace :mentions do
  
  desc "Start twitter daemon"
  task :twitter, [:filters] => :environment do |t,args|
    filters = args[:filters].gsub("-", ",")
    `ruby script/twitter start #{filters}`
  end
  
  desc "Start facebook daemon"
  task :facebook, [:filters] => :environment do |t,args|
    filters = args[:filters].gsub("-", ",")
    `ruby script/facebook_daemon start #{filters}`
  end
  
end