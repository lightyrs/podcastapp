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
  
  # Fetch the latest episodes for the podcast
  def self.fetch_podcast_episodes(podcast)
    @podcast = Podcast.find(podcast)
    @feed = @podcast.feedurl
    puts "#{@feed}"
    
    @doc = Nokogiri.XML(open(@feed))
    @episodes = @doc.xpath("//item")
    
    @episodes.each do |episode|
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
      
      # Episode file size
      episode_file_size = episode.xpath("./itunes:duration").text
      
      if episode_file_size.nil? || episode_file_size == ""
        episode_file_size = episode.xpath("./enclosure/@length").text
      end
      
      episode_file_size = (episode_file_size.to_f / 1048576.0).round(1).to_s + " MB"
      
      # Episode Duration
      
      puts "TITLE => #{episode_title}"
      puts "SHOWNOTES => #{episode_shownotes}"
      puts "DATE PUBLISHED => #{episode_pub_date}"
      puts "FILE SIZE => #{episode_file_size}"
    end
  end
end