###################################################################################################
#
# Rake: podcast
# This task runs all of the various scraping methods in the Podcast class
#
###################################################################################################

namespace :podcast do
  
  desc "Scrape the Top 300 Podcasts from iTunes"
  task :itunes_top_300, [:scope] => :environment do |t,args|
    if args[:scope] == "new"
      Podcast.podcast_logger.info("NEW_PODCASTS_ONLY")
    end
    Podcast.podcast_logger.info("BEGIN: #{Time.now}")
    Podcast.itunes_top_rss
  end

  desc "Scrape the Top 300 Podcasts in each genre from iTunes"
  task :itunes_genres_top_300 => :itunes_top_300 do
    Podcast.itunes_genre_rss
  end

  desc "Scrape the podcast website url from iTunes Preview"
  task :site_discovery, [:scope] => :itunes_genres_top_300 do |t,args|
    if args[:scope] == "new"
      Podcast.site_discovery(:new_podcasts_only => true)
    else
      Podcast.site_discovery
    end
  end

  desc "Scrape the podcast feed url using imasquerade"
  task :feed_discovery, [:scope] => :site_discovery do |t,args|
    if args[:scope] == "new"
      Podcast.feed_discovery(:new_podcasts_only => args[:scope])
    else
      Podcast.feed_discovery
    end
  end

  desc "Scrape the podcast twitter and facebook urls from the podcast website"
  task :social_discovery, [:scope] => :feed_discovery do |t,args|
    if args[:scope] == "new"
      Podcast.social_discovery(:new_podcasts_only => args[:scope])
    else
      Podcast.social_discovery
    end
  end
  
  desc "This task runs all of the various scraping methods in the Podcast class"
  task :generate_inventory, [:scope] => :social_discovery do |t,args|
    Podcast.podcast_logger.info("Successful Rake")
    Podcast.podcast_logger.info("END #{Time.now}")
  end
  
end