###################################################################################################
#
# Class: Podcast
#
###################################################################################################
require 'nokogiri'
require 'httparty'
require 'will_paginate'

class Podcast < ActiveRecord::Base
  
  has_many :episodes, :dependent => :destroy
  has_and_belongs_to_many :users
  
  validates_uniqueness_of :name
  
  cattr_reader :per_page
  @@per_page = 50
  
  searchable do
    text :name
  end
  
  # Define a custom logger.
  def self.podcast_logger
    @@podcast_logger ||= Logger.new("#{RAILS_ROOT}/log/cron/podcast_cron.log", 3, 524288)
  end
  
  # Generate the iTunes top 300 podcasts url (overall).    
  def self.itunes_top_rss
    itunes_url = "http://itunes.apple.com/us/rss/toppodcasts/limit=300/explicit=true/xml"
    itunes_doc = Nokogiri.HTML(HTTParty.get(itunes_url, :format => :html))
    
    # Scrape that url
    Podcast.scrape_from_itunes(itunes_doc)    
  end
  
  # Generate the iTunes top 300 podcasts url (by genre).
  def self.itunes_genre_rss
    itunes_genre_codes = {}
    
      itunes_genre_codes['arts'] = "1301"
      itunes_genre_codes['business'] = "1321"
      itunes_genre_codes['comedy'] = "1303"
      itunes_genre_codes['education'] = "1304"
      itunes_genre_codes['games_hobbies'] = "1323"
      itunes_genre_codes['goverment_organization'] = "1325"
      itunes_genre_codes['health'] = "1307"
      itunes_genre_codes['kids_family'] = "1305"
      itunes_genre_codes['music'] = "1310"
      itunes_genre_codes['news_politics'] = "1311"
      itunes_genre_codes['religion_spirituality'] = "1314"
      itunes_genre_codes['science_medicine'] = "1315"
      itunes_genre_codes['society_culture'] = "1324"
      itunes_genre_codes['sports_recreation'] = "1316"
      itunes_genre_codes['technology'] = "1318"
      itunes_genre_codes['tv_film'] = "1309"

    itunes_genre_codes.each do |genre, id|
      
      # Create the top 300 url for each genre
      itunes_url = "http://itunes.apple.com/us/rss/toppodcasts/limit=300/genre=#{id}/explicit=true/xml"
      itunes_doc = Nokogiri.HTML(HTTParty.get(itunes_url, :format => :html))
      
      # Scrape that url
      Podcast.scrape_from_itunes(itunes_doc)  
    end
  end 
  
  # Parse the xml returned by iTunes.  
  # If the podcast exists, update attributes.  
  # Otherwise, create a new podcast.
  def self.scrape_from_itunes(itunes_doc)
    itunes_doc.xpath('//feed/entry').map do |entry|
      new_name = entry.xpath("./name").text
      podcast = Podcast.find_all_by_name(new_name)
      if (podcast == [])
        begin
          podcast = Podcast.create(
            :name => entry.xpath("./name").text,
            :itunesurl => entry.xpath("./link/@href").text,
            :category => entry.xpath("./category/@term").text,
            :hosts => entry.xpath("./artist").text,
            :description => entry.xpath("./summary").text,
            :artwork => entry.xpath("./image[@height='170']").text  
          )
          puts "New Podcast: #{podcast.name}"
          Podcast.podcast_logger.info("New Podcast: #{podcast.name}")
        rescue StandardError => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      elsif (!podcast[0].nil?)
        begin
          pod = podcast[0]
          pod.itunesurl = entry.xpath("./link/@href").text
          pod.category = entry.xpath("./category/@term").text
          pod.hosts = entry.xpath("./artist").text
          pod.description = entry.xpath("./summary").text
          pod.artwork = entry.xpath("./image[@height='170']").text
          
          if pod.changed?
            pod.save      
            puts "Update Podcast: #{pod.name}"
            Podcast.podcast_logger.info("Update Podcast: #{pod.name}")
          end
        rescue StandardError => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      else
        puts "StandardError"
      end
    end
  end  
  
  # Scrape the podcast site url and feed url from the iTunes doc.
  def self.site_and_feed_discovery(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcast = Podcast.find(:all, :select => 'id, itunesurl, name', :conditions => ['created_at > ?', Time.now - 24.hours])
      Podcast.podcast_logger.info("#{podcast.count}")
    else
      podcast = Podcast.find(:all, :select => 'id, itunesurl, name')
    end
    podcast.each do | pod |
      begin
        url_hash = Imasquerade::Extractor.parse_itunes_uri(pod.itunesurl)
        
        pod.feedurl = url_hash["feedurl"]
        pod.siteurl = url_hash["siteurl"]
        
        if pod.feedurl_changed? or pod.siteurl_changed?
          pod.save
          puts "#{pod.feedurl}"
          puts "#{pod.siteurl}"
          Podcast.podcast_logger.info("#{pod.feedurl}")
          Podcast.podcast_logger.info("#{pod.siteurl}")
        end
      rescue StandardError => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end
  end  

  # Scrape the podcast twitter and facebook urls from the site doc.
  def self.social_discovery(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcast = Podcast.find(:all, :select => 'id, siteurl, name', :conditions => ['created_at > ?', Time.now - 24.hours])
      Podcast.podcast_logger.info("#{podcast.count}")
    else
      podcast = Podcast.find(:all, :select => 'id, siteurl, name')
    end
    
    # TODO Handle Nokogiri Errno:: Errors
    podcast.each do | pod |
      puts "#{pod.name}"
      begin 
        # Make sure the url is readable by httparty
        if pod.siteurl.include? 'http://'
          pod_site = pod.siteurl
        else
          pod_site = pod.siteurl.insert 0, "http://"
        end
 
        # Skip all of this if we're dealing with a feed
        unless pod_site.downcase =~ /.rss|.xml|libsyn/i
          begin
            pod_doc = Nokogiri.HTML(HTTParty.get(pod_site, 'User-Agent' => 'ruby', :timeout => 15, :limit => 10))
          rescue HTTParty::UnsupportedURIScheme => ex
            dir = ex.message.split("'")[1]
            pod_site = "http://" + pod_site.split("/")[2] + dir
            pod_doc = Nokogiri.HTML(HTTParty.get(pod_site, 'User-Agent' => 'ruby', :timeout => 15, :limit => 10))
          end
          pod_name_fragment = pod.name.split(" ")[0].to_s
          if pod_name_fragment.downcase == "the" or pod_name_fragment.downcase == "a"
            pod_name_fragment = pod.name.split(" ")[1].to_s unless pod.name.split(" ")[1].to_s.nil?
          end
          doc_links = pod_doc.css('a')
          
          # If a social url contains part of the podcast name, grab that.  
          # If not, grab the first one you find within our conditions.  
          # Give Nokogiri some room to breathe with pessimistic StandardError handling.
          begin
            twitter_url = Podcast.social_relevance(doc_links, "twitter.com", pod_name_fragment, "share|status")
            facebook_url = Podcast.social_relevance(doc_links, "facebook.com", pod_name_fragment, "share|.event|placement=")
          # Ensure that the urls get saved regardless of what else happens
          ensure
            pod.twitter = twitter_url
            pod.facebook = facebook_url
            
            if pod.twitter_changed? or pod.facebook_changed?
              pod.save
              puts "#{twitter_url}"
              puts "#{facebook_url}"
              Podcast.podcast_logger.info("#{twitter_url}")
              Podcast.podcast_logger.info("#{facebook_url}")
            end
          end
        end
      rescue StandardError => ex
        puts "FINAL StandardError: #{ex.class} + #{ex.message}"
      end
    end  
  end
  
  # If a social url contains part of the podcast name, grab that.  
  # If not, grab the first one you find within our conditions.  
  # Give Nokogiri some room to breathe with pessimistic StandardError handling.  
  def self.social_relevance(doc_links, social_network, pod_name_fragment, regex)
    begin
      begin       
        social_links = doc_links.find {|link| link['href'].to_s.match(/#{social_network}/i) and link['href'].to_s.match(/#{pod_name_fragment}/i).to_s != "" unless link['href'].to_s.match(/#{regex}/i)}.attribute('href').to_s 
      rescue StandardError
        if doc_links.find {|link| link['href'].to_s.match(/#{social_network}/i) unless link['href'].to_s.match(/#{regex}/i)}.nil?
          social_links = nil
        else       
          social_links = doc_links.find {|link| link['href'].to_s.match(/#{social_network}/i) unless link['href'].to_s.match(/#{regex}/i)}.attribute('href').to_s
        end
      end
    rescue StandardError
      # Ensure that the urls get saved regardless of what else happens
    ensure
      return social_links.to_s    
    end
  end
  
  # Fetch twitter handle from twitter url
  def self.fetch_twitter_handle(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcast = Podcast.find(:all, :select => 'id, twitter, name', :conditions => ['created_at > ? AND twitter IS NOT ? AND twitter != ?', Time.now - 24.hours, nil, ''])
      Podcast.podcast_logger.info("#{podcast.count}")
    else
      podcast = Podcast.find(:all, :select => 'id, twitter, name', :conditions => ['twitter IS NOT ? AND twitter != ?', nil, ''])
    end
    
    podcast.each do | pod |
      begin
        pod_twitter = pod.twitter.gsub("#!/","")
        # Make sure the url is readable by httparty
        unless pod_twitter.include? 'http://'
          pod_twitter = pod_twitter.insert 0, "http://"
        end
        unless pod_twitter.include? "search?q="
          puts "#{pod_twitter}"
          Podcast.podcast_logger.info("#{pod_twitter}")
          twitter_doc = Nokogiri.XML(HTTParty.get(pod_twitter, 'User-Agent' => 'ruby', :timeout => 15, :limit => 10))
          
          handle = "@" + twitter_doc.search(".screen-name").first.text
          if handle.nil? or handle == "@"
            handle = "@" + twitter_doc.search("h2")[1].text.strip
          end
          if handle.nil? or handle == "@"
            handle = "@" + twitter_doc.at_css("h2").text.split("@")[1].gsub(".","")
          end
        end
      rescue StandardError => ex
        puts "#{ex.class}: #{ex.message}"
      ensure
        unless handle.nil? or handle == "@"
          pod.twitter_handle = handle
          
          if pod.twitter_handle_changed?
            pod.save
            puts "#{handle}"
            Podcast.podcast_logger.info("#{handle}")
          end
        end
      end
    end  
  end
  
  # Fetch podcast episodes.
  def self.fetch_episodes(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcasts = Podcast.find(:all, :select => 'id', :conditions => ['created_at > ? and feedurl IS NOT ?', Time.now - 24.hours, nil])
      Podcast.podcast_logger.info("#{podcasts.count}")
    else
      podcasts = Podcast.find(:all, :select => 'id', :conditions => ['feedurl IS NOT ?', nil])
    end

    podcasts.each{|podcast| Episode.fetch_podcast_episodes(podcast.id)}
  end
end