###################################################################################################
#
# Rake: mentions
# This task processes all data from realtime social apis.
#
###################################################################################################

namespace :mentions do
  
  desc "Start twitter daemon"
  task :firehose, [:filters] => :environment do |t,args|
    filters = args[:filters].gsub("-", ",")
    `ruby script/twitter start #{filters}`
  end
  
end