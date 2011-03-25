###################################################################################################
#
# Rake: podcast
# This task runs all of the various scraping methods in the Podcast class
#
###################################################################################################

namespace :podcast do
  
  # Phase One
  
  desc "Scrape the Top 300 Podcasts from iTunes"
  task :itunes_top_300, [:scope] => :environment do |t,args|
    Podcast.itunes_top_rss
  end

  desc "Scrape the Top 300 Podcasts in each genre from iTunes"
  task :itunes_genres_top_300, [:scope] => :itunes_top_300 do |t,args|
    Podcast.itunes_genre_rss
  end

  desc "Scrape the podcast website url and feed url from iTunes Preview"
  task :site_and_feed_discovery, [:scope] => :itunes_genres_top_300 do |t,args|
    if args[:scope] == "new"
      Podcast.site_and_feed_discovery(:new_podcasts_only => true)
    else
      Podcast.site_and_feed_discovery
    end
  end
  
  desc "This task fetches podcasts from iTunes and discovers site and feed URLs"
  task :generate_inventory, [:scope] => :site_and_feed_discovery do |t,args|
    Podcast.podcast_logger.info("***podcast:generate_inventory***")
    Podcast.podcast_logger.info("END #{Time.now}")
  end

  # Phase Two

  desc "Scrape the podcast twitter and facebook urls from the podcast website"
  task :social_discovery, [:scope] => :environment do |t,args|
    if args[:scope] == "new"
      Podcast.social_discovery(:new_podcasts_only => true)
    else
      Podcast.social_discovery
    end
  end
  
  desc "Scrape the twitter handle from the podcast twitter url"
  task :twitter_handle_discovery, [:scope] => :social_discovery do |t,args|
    if args[:scope] == "new"
      Podcast.fetch_twitter_handle(:new_podcasts_only => true)
    else
      Podcast.fetch_twitter_handle
    end    
  end
  
  desc "This task discovers social URLs and twitter handles"
  task :socialize, [:scope] => :twitter_handle_discovery do |t,args|
    Podcast.podcast_logger.info("***podcast:socialize***")
    Podcast.podcast_logger.info("END #{Time.now}")
  end
  
  # Phase Three
  
  desc "Fetch the podcast episodes"
  task :fetch_episodes, [:scope] => :environment do |t,args|
    Episode.episode_logger.info("BEGIN: #{Time.now}")
    Podcast.fetch_episodes
    Episode.episode_logger.info("END: #{Time.now}")
  end
end