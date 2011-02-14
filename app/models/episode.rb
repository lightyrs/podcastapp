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
    @podcast = Podcast.find(podcast)
    @feed = @podcast.feedurl
    puts "#{@feed}"
    
    begin
      @doc = Nokogiri.XML(open(@feed))
      @episodes = @doc.xpath("//item")
    rescue Exception => ex
      puts "#{ex.class}:#{ex.message}"
    end
    
    @episodes.each do |episode|
      begin
        # Grab the episode title
        episode_title = episode.xpath("./title").text
    
        # Let's grab the most robust shownotes we can find
        episode_shownotes_summary = episode.xpath("./itunes:summary").text.gsub(/<\/?[^>]*>/, "")
        episode_shownotes_description = episode.xpath("./description").text.gsub(/<\/?[^>]*>/, "")
        episode_shownotes_subtitle = episode.xpath("./itunes:subtitle").text.gsub(/<\/?[^>]*>/, "")
    
        length = {}
        length["summary"] = episode_shownotes_summary.scan(/[\w-][\w.]+/).size
        length["description"] = episode_shownotes_description.scan(/[\w-][\w.]+/).size
        length["subtitle"] = episode_shownotes_subtitle.scan(/[\w-][\w.]+/).size
    
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
        episode_pub_date = episode.xpath("./pubDate").text

        # Episode file name
        episode_file_name = episode.xpath("./enclosure/@url").text.split("/").last

        # Episode url
        episode_url = episode.xpath("./enclosure/@url").text

        # Episode file type
        episode_file_type = episode.xpath("./enclosure/@type").text

        # Episode file size
        episode_file_size = episode.xpath("./enclosure/@length").text
        episode_file_size = (episode_file_size.to_f / 1048576.0).round(1).to_s + " MB"

        # Episode Duration
        episode_duration = episode.xpath("./itunes:duration").text
    
        unless episode_duration.include? ":"
          episode_duration = Time.at(episode_duration.to_i).gmtime.strftime("%R:%S")
        end
        
        episode = Episode.find(:all, :conditions => {:title => episode_title})
        
        if episode == []
          begin
            episode = Episode.new(
              :podcast_id => @podcast.id,
              :title => episode_title,
              :shownotes => episode_shownotes,
              :date_published => episode_pub_date,
              :filename => episode_file_name,
              :url => episode_url,
              :filetype => episode_file_type,
              :size => episode_file_size,
              :duration => episode_duration
            )
            episode.save
            puts "New Episode: #{episode.title}"
            Episode.episode_logger.info("New Episode: #{episode.title}")
          rescue Exception => ex
            puts "An error of type #{ex.class} happened, message is #{ex.message}"
          end        
        elsif
          begin
            Episode.find(episode[0].id).update_attributes(
              :shownotes => episode_shownotes,
              :date_published => episode_pub_date,
              :filename => episode_file_name,
              :url => episode_url,
              :filetype => episode_file_type,
              :size => episode_file_size,
              :duration => episode_duration         
            )
            puts "Update Episode: #{episode[0].title}"
            Episode.episode_logger.info("Update Episode: #{episode[0].title}")
          rescue Exception => ex
            puts "An error of type #{ex.class} happened, message is #{ex.message}"
          end          
        end
      rescue Exception => ex
        puts "#{ex.class}:#{ex.message}"
      end
    end
  end
end