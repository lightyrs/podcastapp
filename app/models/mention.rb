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
  
  def self.twitter_search(text, reply)
    # Initialize a Twitter search
    search = Twitter::Search.new

    # Find recent tweets using the given params
    search.containing(text).to(reply).result_type("recent").per_page(3).each do |r|
      puts "#{r.from_user}: #{r.text}"
    end

    # Clear the search
    search.clear
  end
end