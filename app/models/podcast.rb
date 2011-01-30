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
  
  validates_uniqueness_of :name
  
  cattr_reader :per_page
  @@per_page = 50
  
  def self.itunes_top_rss
    
    # create the top 300 url
    itunes_url = "http://itunes.apple.com/us/rss/toppodcasts/limit=300/explicit=true/xml"
    itunes_doc = Nokogiri.HTML(open(itunes_url))
    
    # scrape that url=
    Podcast.scrape_from_itunes(itunes_doc)    
  end
  
  def self.itunes_genre_rss
  
    # podcast genres from itunes
    itunes_genre_codes = {}
    
      itunes_genre_codes['arts'] = "1301"
      itunes_genre_codes['business'] = "1321"
      itunes_genre_codes['comedy'] = "1303"
      itunes_genre_codes['education'] = "1304"
      itunes_genre_codes['games_hobbies'] = "1323"
      itunes_genre_codes['goverment_organization'] = "1325"
      itunes_genre_codes['health '] = "1307"
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
      
      # create the top 300 url for each genre
      itunes_url = "http://itunes.apple.com/us/rss/toppodcasts/limit=300/genre=#{id}/explicit=true/xml"
      itunes_doc = Nokogiri.HTML(open(itunes_url))
      
      # scrape that url
      Podcast.scrape_from_itunes(itunes_doc)  
    end
  end
  
  
  # parse the returned xml
  # if the podcast exists, update attributes
  # otherwise, create a new podcast

  def self.scrape_from_itunes(itunes_doc)
    itunes_doc.xpath('//feed/entry').map do |entry|
      new_name = entry.xpath("./name").text
      podcast = Podcast.find(:all, :conditions => {:name => new_name})
      if (podcast == [])
        begin
          puts "creating"
          podcast = Podcast.new(
            :name => entry.xpath("./name").text,
            :itunesurl => entry.xpath("./link/@href").text,
            :category => entry.xpath("./category/@term").text,
            :hosts => entry.xpath("./artist").text,
            :description => entry.xpath("./summary").text,
            :artwork => entry.xpath("./image[@height='170']").text  
          )
          podcast.save
          puts "New Podcast: #{podcast[0].name}"
        rescue Exception => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      elsif (!podcast[0].name.nil?)
        begin
          puts "updating"
          Podcast.find(podcast[0].id).update_attributes(
            :itunesurl => entry.xpath("./link/@href").text,
            :category => entry.xpath("./category/@term").text,
            :hosts => entry.xpath("./artist").text,
            :description => entry.xpath("./summary").text,
            :artwork => entry.xpath("./image[@height='170']").text            
          )
          puts "Update Podcast: #{podcast[0].name}"
        rescue Exception => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
      else
        puts "Exception"
      end
    end
  end
  
  
  # scrape the podcast site url from the itunes doc
  
  def self.site_discovery
    podcast = Podcast.find(:all, :conditions => {:siteurl => nil})
    podcast.each do | pod |
      begin
        itunes_doc = Nokogiri.HTML(open(pod.itunesurl))
        site_url = itunes_doc.xpath('//div[@id="left-stack"]/div[@metrics-loc="Titledbox_Links"]/ul/li[1]/a')
        Podcast.find(pod.id).update_attributes(:siteurl => site_url.attribute("href").to_s)
        puts site_url.attribute("href").to_s
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end
  end
  
  
  # discover the podcast feed using imasquerade
  
  def self.feed_discovery
    podcast = Podcast.where("itunesurl IS NOT ?", nil)
    podcast.each do | pod |
      begin
        itunes_uri = pod.itunesurl
        feed_url = Imasquerade::Extractor.parse_itunes_uri(itunes_uri)
        Podcast.find(pod.id).update_attributes(:feedurl => feed_url)
        puts "#{feed_url}"
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end
  end
  
  
  # scrape the podcast twitter and facebook urls from the site doc
  
  def self.social_discovery
    podcast = Podcast.where("siteurl IS NOT ?", nil)
    podcast.each do | pod |
      begin
        pod_site = pod.siteurl
        begin
          pod_doc = Nokogiri.HTML(open(pod_site))
          twitter_url = pod_doc.search('a').find {|link| link['href'].include? 'twitter.com/'}.attribute('href').to_s
          facebook_url = pod_doc.search('a').find {|link| link['href'].include? 'facebook.com/'}.attribute('href').to_s
          puts "#{twitter_url}" + "#{facebook_url}"
        rescue Exception => ex
          puts "An error of type #{ex.class} happened, message is #{ex.message}"
        end
        Podcast.find(pod.id).update_attributes(:twitter => twitter_url, :facebook => facebook_url)
      rescue Exception => ex
        puts "An error of type #{ex.class} happened, message is #{ex.message}"
      end
    end    
  end
  
end