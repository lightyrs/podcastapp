class UsersController < ApplicationController
	
	def show
	  @user = User.find(params[:id])
    @page_title = @user.email

	  respond_to do |format|
	    format.html # index.html.erb
	  end
	end
	
	def subscribe
	  @podcast = Podcast.find(params[:id])
	  
	  if current_user
	    @user = current_user
	    @user.podcasts << @podcast unless @user.podcasts.include?(@podcast)
	  end
	  
	  respond_to do |format|
	    if @user && @user.save
	      format.html { redirect_to(@podcast, :notice => "You are now subscribed to #{@podcast.name}") }
	    else
	      format.html { redirect_to(@podcast, :notice => "Sign Up or Sign In to subscribe.") }
	    end
	  end
	end
	
end