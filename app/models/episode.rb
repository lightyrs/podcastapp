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
  
end