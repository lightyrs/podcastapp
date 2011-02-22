###################################################################################################
#
# Class: Episode
#
###################################################################################################
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'will_paginate'

class Episode < ActiveRecord::Base

  belongs_to :podcast
  
  validates_uniqueness_of :title, :scope => :podcast_id

  # Define a custom logger  
  def self.episode_logger
    @@episode_logger ||= Logger.new("#{RAILS_ROOT}/log/episode_cron.log", 3, 524288)
  end
  
  # Fetch the latest episodes for the podcast
  def self.fetch_podcast_episodes(podcast)
    
    @podcast = Podcast.find(podcast, :select => 'id, name, feedurl')
    @feed = @podcast.feedurl
    puts "#{@feed}"
    
    @podcast.update_attributes :episode_update_status => 'started'
    
    begin
      @doc = Nokogiri.XML(open(@feed, :read_timeout => 15.00)).remove_namespaces!
      @episodes = @doc.xpath("//item")
    rescue StandardError => ex
      puts "#{ex.class}:#{ex.message}"
    end
    
    @episodes.each do |episode|
      begin
        # Grab the episode title
        episode_title = Episode.parse_nodes(episode.at_xpath("./title"))
    
        # Let's grab the most robust shownotes we can find
        episode_shownotes_summary = Episode.parse_nodes(episode.at_xpath("./summary"))
        episode_shownotes_description = Episode.parse_nodes(episode.at_xpath("./description"))
        episode_shownotes_subtitle = Episode.parse_nodes(episode.at_xpath("./subtitle"))
    
        length = {}
        length["summary"] = episode_shownotes_summary.scan(/[\w-][\w.]+/).size unless episode_shownotes_summary.nil?
        length["description"] = episode_shownotes_description.scan(/[\w-][\w.]+/).size unless episode_shownotes_description.nil?
        length["subtitle"] = episode_shownotes_subtitle.scan(/[\w-][\w.]+/).size unless episode_shownotes_subtitle.nil?
    
        max_length = length.values.max
        shownotes = length.key(max_length)

        if shownotes == "summary"
          episode_shownotes = episode_shownotes_summary
        elsif shownotes == "description"
          episode_shownotes = episode_shownotes_description
        elsif shownotes == "subtitle"
          episode_shownotes = episode_shownotes_subtitle
        end

        # Episode publish date
        episode_pub_date = Episode.parse_nodes(episode.at_xpath("./pubDate"))

        # Episode url
        episode_url = Episode.parse_nodes(episode.at_xpath("./enclosure/@url"))
        
        if episode_url.nil?
          episode_url = Episode.parse_nodes(episode.at_xpath("./content/@url"))
        end

        # Episode file type
        episode_file_type = Episode.parse_nodes(episode.at_xpath("./enclosure/@type"))
        
        if episode_file_type.nil?
          episode_file_type = Episode.parse_nodes(episode.at_xpath("./content/@type"))
        end        

        # Episode file size
        episode_file_size = Episode.parse_nodes(episode.at_xpath("./enclosure/@length"))
        
        if episode_file_size.nil?
          episode_file_size = Episode.parse_nodes(episode.at_xpath("./content/@filesize"))
        end        
        
        episode_file_size = (episode_file_size.to_f / 1048576.0).round(1).to_s + " MB"

        # Episode Duration
        episode_duration = Episode.parse_nodes(episode.at_xpath("./duration"))
    
        unless episode_duration.nil? or episode_duration.include? ":"
          episode_duration = Time.at(episode_duration.to_i).gmtime.strftime("%R:%S")
        end
        
        episode = @podcast.episodes.find(:all, :conditions => {:title => episode_title})
        
        if (episode == [])
          begin
            episode = Episode.new(
              :podcast_id => @podcast.id,
              :title => episode_title,
              :shownotes => episode_shownotes,
              :date_published => episode_pub_date,
              :url => episode_url,
              :filetype => episode_file_type,
              :size => episode_file_size,
              :duration => episode_duration
            )
            episode.save
            puts "New Episode: #{episode.title}"
            Episode.episode_logger.info("New Episode: #{episode.title}")
          rescue StandardError => ex
            puts "An error of type #{ex.class} happened, message is #{ex.message}"
          end     
        elsif (!episode[0].title.nil?)
          begin
            episode[0].update_attributes(
              :shownotes => episode_shownotes,
              :date_published => episode_pub_date,
              :url => episode_url,
              :filetype => episode_file_type,
              :size => episode_file_size,
              :duration => episode_duration         
            )
            puts "Update Episode: #{episode[0].title}"
            Episode.episode_logger.info("Update Episode: #{episode[0].title}")
          rescue StandardError => ex
            puts "An error of type #{ex.class} happened, message is #{ex.message}"
          end          
        end
      rescue StandardError => ex
        puts "#{ex.class}:#{ex.message}"
        @podcast.update_attributes :episode_update_status => 'error'
      end
    end
    @podcast.update_attributes :episode_update_status => 'success'
  end
  
  def self.parse_nodes(xpath)
    node_value = xpath.text unless xpath.nil?
    return node_value
  end
end