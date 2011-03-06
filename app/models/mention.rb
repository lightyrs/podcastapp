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
  
  def self.twitter_engine
    collection = Podcast.find(:all, :select => 'id, name', :conditions => ["id between ? and ?", 0, 400])
    query = collection.map { |q|
      name = q.name[0..24]
      length = name.split(" ").length - 2
      name = name.split(" ")[0..length].join(" ")
      unless name.include? "podcast"
        name + " podcast"
      end
    }
    puts "#{query}"
    
    # Open up a twitter firehose with our query
    TweetStream::Client.new('theMTA', 'matt22').on_error do |message|
      puts "#{message}"
    end.track(query.join(",")) do |status|
      # Append the tweet to a local file. Create one if the file doesn't exist.
      current = Time.now.to_s.slice(0..13).gsub(":", "").gsub(" ", "_") + ".log"
      File.open("#{RAILS_ROOT}/log/twitter/mentions/#{current}", 'a') {|f| f.write(status.text + "\n") }
      puts "#{status.text}"
    end    
  end
end