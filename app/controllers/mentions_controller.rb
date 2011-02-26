class MentionsController < ApplicationController
  # GET /mentions
  # GET /mentions.xml
  def index
    @mentions = Mention.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mentions }
    end
  end

  # GET /mentions/1
  # GET /mentions/1.xml
  def show
    @mention = Mention.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mention }
    end
  end

  # GET /mentions/new
  # GET /mentions/new.xml
  def new
    @mention = Mention.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mention }
    end
  end

  # GET /mentions/1/edit
  def edit
    @mention = Mention.find(params[:id])
  end

  # POST /mentions
  # POST /mentions.xml
  def create
    @mention = Mention.new(params[:mention])

    respond_to do |format|
      if @mention.save
        format.html { redirect_to(@mention, :notice => 'Mention was successfully created.') }
        format.xml  { render :xml => @mention, :status => :created, :location => @mention }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mention.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mentions/1
  # PUT /mentions/1.xml
  def update
    @mention = Mention.find(params[:id])

    respond_to do |format|
      if @mention.update_attributes(params[:mention])
        format.html { redirect_to(@mention, :notice => 'Mention was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mention.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mentions/1
  # DELETE /mentions/1.xml
  def destroy
    @mention = Mention.find(params[:id])
    @mention.destroy

    respond_to do |format|
      format.html { redirect_to(mentions_url) }
      format.xml  { head :ok }
    end
  end
end
