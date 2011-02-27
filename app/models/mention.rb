###################################################################################################
#
# Class: Mention
#
###################################################################################################
require 'koala'
require 'twitter'

class Mention < ActiveRecord::Base
  
  belongs_to :podcast 

  # Define a custom logger. 
  def self.mention_logger
    @@mention_logger ||= Logger.new("#{RAILS_ROOT}/log/mention_cron.log", 3, 524288)
  end
end