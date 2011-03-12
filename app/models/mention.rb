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
require 'classifier'
require 'madeleine'

class Mention < ActiveRecord::Base
  
  belongs_to :podcast 

  # Define a custom logger. 
  def self.mention_logger
    @@mention_logger ||= Logger.new("#{RAILS_ROOT}/log/cron/mention_cron.log", 3, 524288)
  end
  
  # Twitter sentiment analysis with the tweetfeel api.
  def self.tweetfeel(query)
    api_key = "SElZYChiRn7riNKYfR7vL-DAPMwG_l8I"
    
    # The TweetFeel API is accessed using HTTP GET requests to the following URL:
    api_url = "http://svc.webservius.com/v1/tweetFeel/tfapi?wsvKey=#{api_key}&keyword=#{CGI::escape(query)}&type=all&maxresults=1500"
    
    begin
      tweets = HTTParty.get(api_url)["tweets"]
      # Filter positive tweets
      tweets.each do |tweet| 
        tweet["tweet"]
      end
    rescue StandardError
      # Save us
    end
  end
  
  # Harvest salient data from our log files
  def self.harvest_mentions
    twitter_logs = Mention.get_recursive_file_list("#{RAILS_ROOT}/log/twitter")
    facebook_logs = Mention.get_recursive_file_list("#{RAILS_ROOT}/log/facebook")
    logs = twitter_logs.concat(facebook_logs)
    
    mentions = Mention.mentions_array_builder(logs)
    Mention.filter_mentions(mentions)
  end
  
  # Prepare the array of mentions for parsing
  def self.mentions_array_builder(logs)
    decoder = "CX3NP47VNND:  "
    
    raw = []
    logs.each do |log|
      if log.include? "facebook"
        network = "facebook"
      elsif log.include? "twitter"
        network = "twitter"
      end
      f = File.open(log, "r").each do |line|
        raw << line.gsub(decoder, "").strip.insert(0, ")))" + network + ")))")
      end
      File.delete(f)
    end
    raw = raw.split(decoder)[0]
  end
  
  # Find mentions of specific podcasts
  def self.filter_mentions(mentions)
    podcasts = Podcast.find(:all, :select => ["id, name, twitter_handle"], :conditions => ["name IS NOT ?", nil])
  
    podcasts.each do |pod|
      begin
        pod_name = pod.name[0..30]        
        
        if pod_name.length < 30
          pod_name = pod_name.downcase
        else
          length = pod_name.split(" ").length - 2
          pod_name = pod_name.split(" ")[0..length].join(" ").downcase
        end
        
        pod_words = pod_name.split(" ")
        name_length = pod_words.length
        
        podcast = pod.id
        
        # Make sure we only get relevant results
        if name_length == 1 or pod_name.length < 6 or pod_name == "podcast"
          if name_length == 2 and pod_words[0].length < 5 and pod_words[1] == "podcast"
            if name_length == 2 and pod_words[0].length < 5 and pod_words[0].include? "ast"
              search_by_name = false
            else
              search_by_name = false
            end
          else
            search_by_name = false         
          end
        else
          search_by_name = true          
        end
        
        if pod.twitter_handle.nil? or pod.twitter_handle == ""
          search_by_handle = false
        else
          search_by_handle = true
        end
        
        # Filter and create
        mentions.each do |mention|
          if search_by_name == true and search_by_handle == true
            if mention.downcase.include? "#{pod_name}"
              Mention.create_mention(mention, podcast)
            elsif mention.downcase.include? "#{pod.twitter_handle}"
              Mention.create_mention(mention, podcast)              
            end
          elsif search_by_name == false and search_by_handle == true
            if mention.downcase.include? "#{pod.twitter_handle}"
              Mention.create_mention(mention, podcast)
            end
          elsif search_by_name == true and search_by_handle == false
            if mention.downcase.include? "#{pod_name}"
              Mention.create_mention(mention, podcast)
            end
          end
        end
      rescue StandardError => ex
        puts "#{ex.class}: #{ex.message}"
      end
    end
  end
  
  def self.create_mention(mention, podcast)
    mention = mention.split(")))")
    network = mention[1]
    
    Mention.create(
      :mention => mention[2],
      :network => network,
      :podcast_id => podcast
    )
    puts "#{mention[2]}"
    sleep(0.0500)    
  end
  
  # Train our classifier to recognize various sentiments
  def self.train_classifier(sample)
    m = SnapshotMadeleine.new("log/bayes_data") {
        Classifier::Bayes.new :categories => ['positive', 'negative']
    }
    tweets = Mention.tweetfeel(sample).map{ |s| s["type"] + s["tweet"] }
    tweets.each do |tweet|
      type = tweet[0..2]
      if type == "pos"
        m.system.train_positive "#{tweet[3..100000]}"
        puts "POSITIVE: #{tweet[3..100000]}"
      elsif type == "neg"
        m.system.train_negative "#{tweet[3..100000]}"
        puts "NEGATIVE: #{tweet[3..100000]}"
      end
    end
    m.take_snapshot
  end
  
  # Classify
  def self.classify(sample)
    m = SnapshotMadeleine.new("log/bayes_data") {
        Classifier::Bayes.new :categories => ['positive', 'negative']
    }
    m.system.classify "#{sample}"
  end
  
  # Crawl the log directory and return a list of all files
  def self.get_recursive_file_list(dirname)
    results = Array.new
    
    use_method = 0
    if use_method == 0
      Dir["#{dirname}/**/**"].each do | thisfile |
        thisfile.gsub!(/\//,'/')
        results.push (thisfile)
      end
    else
      require 'find'
      Find.find ( dirname ) do | thisfile |
        thisfile.gsub!(/\//,'\\')
        results.push (thisfile)
      end
    end
    return results
  end
end