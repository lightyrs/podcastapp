class UsersController < ApplicationController
	
	def index
	  @user = current_user

	  respond_to do |format|
	    format.html # index.html.erb
	  end
	end	
	
end