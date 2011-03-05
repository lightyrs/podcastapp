###################################################################################################
#
# Class: Mention
#
###################################################################################################
require 'koala'
require 'twitter'
require 'tweetstream'
require 'nokogiri'
require 'httparty'

class Mention < ActiveRecord::Base
  
  belongs_to :podcast 

  # Define a custom logger. 
  def self.mention_logger
    @@mention_logger ||= Logger.new("#{RAILS_ROOT}/log/cron/mention_cron.log", 3, 524288)
  end
  
  # Twitter sentiment analysis with the tweetfeel api.
  def self.tweetfeel(podcast, query)
    api_key = "SElZYChiRn7riNKYfR7vL-DAPMwG_l8I"
    
    # The TweetFeel API is accessed using HTTP GET requests to the following URL:
    api_url = "http://svc.webservius.com/v1/tweetFeel/tfapi?wsvKey=#{api_key}&keyword=#{CGI::escape(query)}&type=all&maxresults=1500"
    
    begin
      score = HTTParty.get(api_url)['score'].to_f   
      unless score == 0.0
        podcast.update_attributes(:sentiment => score)
      end      
      puts "#{score}"
    rescue StandardError
      # Save us
    end
  end
end