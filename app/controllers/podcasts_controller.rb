class PodcastsController < ApplicationController
  
  autocomplete :podcast, :name
  
  # GET /podcasts
  # GET /podcasts.xml
  def index
    @page_title = false
    @podcasts = Podcast.paginate :page => params[:page], :per_page => 50
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @podcasts }
    end
  end
  
  # Search podcasts
  def search
    @page_title = "Search"
    @search = Sunspot.search(Podcast) do
      keywords(params[:q])
      paginate(:page => params[:page])
    end
    
    @result_count = @search.total
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @podcasts }
    end
  end
  
  # Return episode update status to ajax request
  def get_update_status
    @podcast = Podcast.find(params[:id])

    respond_to do |format|
      format.js { render :json => @podcast.episode_update_status }
    end
  end
  
  # Reset update status after successful update
  def reset_update_status
    @podcast = Podcast.find(params[:id])
    @podcast.update_attributes :episode_update_status => "reset"

    respond_to do |format|
      format.js { render :json => "reset" }
    end
  end

  # GET /podcasts/1
  # GET /podcasts/1.xml
  def show
    @podcast = Podcast.find(params[:id])
    @pod_name = Podcast.find(@podcast).name
    @page_title = @pod_name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @podcast }
    end
  end

  # GET /podcasts/new
  # GET /podcasts/new.xml
  def new
    @podcast = Podcast.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @podcast }
    end
  end

  # GET /podcasts/1/edit
  def edit
    @podcast = Podcast.find(params[:id])
  end

  # POST /podcasts
  # POST /podcasts.xml
  def create
    @podcast = Podcast.new(params[:podcast])

    respond_to do |format|
      if @podcast.save
        format.html { redirect_to(@podcast, :notice => 'Podcast was successfully created.') }
        format.xml  { render :xml => @podcast, :status => :created, :location => @podcast }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /podcasts/1
  # PUT /podcasts/1.xml
  def update
    @podcast = Podcast.find(params[:id])

    respond_to do |format|
      if @podcast.update_attributes(params[:podcast])
        format.html { redirect_to(@podcast, :notice => 'Podcast was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /podcasts/1
  # DELETE /podcasts/1.xml
  def destroy
    @podcast = Podcast.find(params[:id])
    @podcast.destroy

    respond_to do |format|
      format.html { redirect_to(podcasts_url) }
      format.xml  { head :ok }
    end
  end
end
