###################################################################################################
#
# Class: Podcast
#
###################################################################################################
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'will_paginate'

class Podcast < ActiveRecord::Base
  
  has_many :episodes, :dependent => :destroy
  
  validates_uniqueness_of :name
  
  cattr_reader :per_page
  @@per_page = 50
  
  searchable do
    text :name
  end
  
  # Define a custom logger  
  def self.podcast_logger
    @@podcast_logger ||= Logger.new("#{RAILS_ROOT}/log/podcast_cron.log", 3, 524288)
  end
  
  # Create the top 300 url      
  def self.itunes_top_rss
    itunes_url = "http://itunes.apple.com/us/rss/toppodcasts/limit=300/explicit=true/xml"
    itunes_doc = Nokogiri.HTML(open(itunes_url))
    
    # Scrape that url
    Podcast.scrape_from_itunes(itunes_doc)    
  end
  
  # Podcast genres from itunes
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
      itunes_doc = Nokogiri.HTML(open(itunes_url))
      
      # Scrape that url
      Podcast.scrape_from_itunes(itunes_doc)  
    end
  end 
  
  # Parse the returned xml
  # If the podcast exists, update attributes
  # Otherwise, create a new podcast
  def self.scrape_from_itunes(itunes_doc)
    itunes_doc.xpath('//feed/entry').map do |entry|
      new_name = entry.xpath("./name").text
      podcast = Podcast.find(:all, :conditions => {:name => new_name})
      if (podcast == [])
        begin
          podcast = Podcast.new(
            :name => entry.xpath("./name").text,
            :itunesurl => entry.xpath("./link/@href").text,
            :category => entry.xpath("./category/@term").text,
            :hosts => entry.xpath("./artist").text,
            :description => entry.xpath("./summary").text,
            :artwork => entry.xpath("./image[@height='170']").text  
          )
          podcast.save
          puts "New Podcast: #{podcast.name}"
          Podcast.podcast_logger.info("New Podcast: #{podcast.name}")
        rescue Exception => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      elsif (!podcast[0].name.nil?)
        begin
          Podcast.find(podcast[0].id).update_attributes(
            :itunesurl => entry.xpath("./link/@href").text,
            :category => entry.xpath("./category/@term").text,
            :hosts => entry.xpath("./artist").text,
            :description => entry.xpath("./summary").text,
            :artwork => entry.xpath("./image[@height='170']").text            
          )
          puts "Update Podcast: #{podcast[0].name}"
          Podcast.podcast_logger.info("Update Podcast: #{podcast[0].name}")
        rescue Exception => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      else
        puts "Exception"
      end
    end
  end  
  
  # Scrape the podcast site url from the itunes doc
  # TODO: Make this faster
  def self.site_discovery(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcast = Podcast.find(:all, :select => 'itunesurl, name', :conditions => ['created_at > ?', Time.now - 24.hours])
      Podcast.podcast_logger.info("#{podcast.count}")
    else
      podcast = Podcast.find(:all, :select => 'itunesurl, name')
    end
    podcast.each do | pod |
      begin
        site_url = Nokogiri.HTML(open(pod.itunesurl)).xpath("//a[text()='Podcast Website']/@href").text
        pod.update_attributes(:siteurl => site_url)
        puts "#{site_url}"
        Podcast.podcast_logger.info(site_url)
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end
  end  
  
  # Discover the podcast feed using imasquerade
  def self.feed_discovery(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcast = Podcast.find(:all, :select => 'itunesurl, name', :conditions => ['created_at > ? and itunesurl IS NOT ?', Time.now - 24.hours, nil])
      Podcast.podcast_logger.info("#{podcast.count}")
    else
      podcast = Podcast.find(:all, :select => 'itunesurl, name', :conditions => ['itunesurl IS NOT ?', nil])
    end
    podcast.each do | pod |
      begin
        itunes_uri = pod.itunesurl
        feed_url = Imasquerade::Extractor.parse_itunes_uri(itunes_uri)
        pod.update_attributes(:feedurl => feed_url)
        puts "#{feed_url}"
        Podcast.podcast_logger.info("#{feed_url}")
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end
  end  

  # Scrape the podcast twitter and facebook urls from the site doc
  # TODO Handle Nokogiri Errno:: Errors, Facebook iframe urls 
  def self.social_discovery(options = {})
    new_podcasts_only = options[:new_podcasts_only] || false
    if new_podcasts_only
      podcast = Podcast.find(:all, :select => 'siteurl, name', :conditions => ['created_at > ? and siteurl IS NOT ?', Time.now - 24.hours, nil])
      Podcast.podcast_logger.info("#{podcast.count}")
    else
      podcast = Podcast.find(:all, :select => 'siteurl, name', :conditions => ['siteurl IS NOT ?', nil])
    end
    
    podcast.each do | pod |
      puts "#{pod.name}"
      begin 
        # Make sure the url is readable by open-uri
        if pod.siteurl.include? 'http://'
          pod_site = pod.siteurl
        else
          pod_site = pod.siteurl.insert 0, "http://"
        end
 
        # Skip all of this if we're dealing with a feed
        unless pod_site.downcase =~ /.rss|.xml|libsyn/i
          pod_doc = Nokogiri.HTML(open(pod_site))
          pod_name_fragment = pod.name.split(" ")[0].to_s
          if pod_name_fragment.downcase == "the"
            pod_name_fragment = pod.name.split(" ")[1].to_s unless pod.name.split(" ")[1].to_s.nil?
          end
          doc_links = pod_doc.css('a')
          
          # If a social url contains part of the podcast name, grab that
          # If not, grab the first one you find within our conditions
          # Give Nokogiri some room to breathe with pessimistic exception handling
          begin
            begin         
              twitter_url = doc_links.find {|link| link['href'] =~ /twitter.com\// and link['href'].match(/#{pod_name_fragment}/i).to_s != "" unless link['href'] =~ /share|status/i}.attribute('href').to_s 
            rescue Exception => ex
              if doc_links.find {|link| link['href'] =~ /twitter.com\// unless link['href'] =~ /share|status/i}.nil?
                twitter_url = nil
              else       
                twitter_url = doc_links.find {|link| link['href'] =~ /twitter.com\// unless link['href'] =~ /share|status/i}.attribute('href').to_s
              end
            end

            begin    
              facebook_url = doc_links.find {|link| link['href'] =~ /facebook.com\// and link['href'].match(/#{pod_name_fragment}/i).to_s != "" unless link['href'] =~ /share|.event/i}.attribute('href').to_s
            rescue Exception => ex
              if doc_links.find {|link| link['href'] =~ /facebook.com\// unless link['href'] =~ /share|.event/i}.nil?
                facebook_url = nil
              else       
                facebook_url = doc_links.find {|link| link['href'] =~ /facebook.com\// unless link['href'] =~ /share|.event/i}.attribute('href').to_s
              end
            end
          rescue Exception => ex
            puts "ANTISOCIAL"
          # Ensure that the urls gets saved regardless of what else happens
          ensure
            pod.update_attributes(:twitter => twitter_url, :facebook => facebook_url)            
          end
          
          puts "#{twitter_url}" + "#{facebook_url}"
          Podcast.podcast_logger.info("#{twitter_url}" + "#{facebook_url}")
        end
      rescue Exception => ex
        puts "FINAL EXCEPTION: #{ex.class} + #{ex.message}"
      end
    end  
  end
end