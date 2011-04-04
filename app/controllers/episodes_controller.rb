class EpisodesController < ApplicationController
  
  before_filter :get_required_assets 
  
  # GET /episodes
  # GET /episodes.xml
  def index
    @podcast = Podcast.find(params[:podcast_id])
    @page_title = @podcast.name + " &raquo; Episodes"
    
    # Don't bother fetching new episodes if we just did or if we're calling #index with comet
    @dont_bother = @podcast.updated_at > Time.now - 10.minutes || params[:reload] == "true"
    
    unless @dont_bother
      # Fetch new episodes in a background task
      Episode.delay.fetch_podcast_episodes(@podcast, :comet => true)
    end
    
    # Find all podcast episodes and sort by date descending
    @episodes = @podcast.episodes.all.sort {|a, b|
      if a.date_published.nil? or b.date_published.nil?
        b.date_published <=> a.date_published
      else
        b.date_published.to_time <=> a.date_published.to_time
      end
    }.paginate :page => params[:page], :per_page => 10

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @episodes }
      format.js { render :layout => false }
    end
  end

  # GET /episodes/1
  # GET /episodes/1.xml
  def show
    @episode = Episode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @episode }
    end
  end

  # GET /episodes/new
  # GET /episodes/new.xml
  def new
    @episode = Episode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @episode }
    end
  end

  # GET /episodes/1/edit
  def edit
    @episode = Episode.find(params[:id])
  end

  # POST /episodes
  # POST /episodes.xml
  def create
    @episode = Episode.new(params[:episode])

    respond_to do |format|
      if @episode.save
        format.html { redirect_to(@episode, :notice => 'Episode was successfully created.') }
        format.xml  { render :xml => @episode, :status => :created, :location => @episode }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @episode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /episodes/1
  # PUT /episodes/1.xml
  def update
    @episode = Episode.find(params[:id])

    respond_to do |format|
      if @episode.update_attributes(params[:episode])
        format.html { redirect_to(@episode, :notice => 'Episode was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @episode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.xml
  def destroy
    @episode = Episode.find(params[:id])
    @episode.destroy

    respond_to do |format|
      format.html { redirect_to(episodes_url) }
      format.xml  { head :ok }
    end
  end
  
  def get_required_assets
    @asset_group_css = :episodes 
  end
end
