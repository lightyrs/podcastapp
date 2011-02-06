###################################################################################################
#
# Rake: podcast
# This task runs all of the various scraping methods in the Podcast class
#
###################################################################################################

namespace :podcast do
  
  desc "Scrape the Top 300 Podcasts from iTunes"
  task :itunes_top_300 => :environment do
    Podcast.itunes_top_rss
  end

  desc "Scrape the Top 300 Podcasts in each genre from iTunes"
  task :itunes_genres_top_300 => [:environment, :itunes_top_300] do
    Podcast.itunes_genre_rss
  end

  desc "Scrape the podcast website url from iTunes Preview"
  task :site_discovery => [:environment, :itunes_top_300, :itunes_genres_top_300] do
    Podcast.site_discovery
  end

  desc "Scrape the podcast feed url using imasquerade"
  task :feed_discovery => [:environment, :itunes_top_300, :itunes_genres_top_300, :site_discovery] do
    Podcast.feed_discovery
  end

  desc "Scrape the podcast twitter and facebook urls from the podcast website"
  task :social_discovery => [:environment, :itunes_top_300, :itunes_genres_top_300, :site_discovery, :feed_discovery] do
    Podcast.social_discovery
  end
  
  desc "This task runs all of the various scraping methods in the Podcast class"
  task :generate_inventory => [:environment, :itunes_top_300, :itunes_genres_top_300, :site_discovery, :feed_discovery, :social_discovery] do
    Podcast.podcast_logger.info("Successful Rake")
  end
  
end