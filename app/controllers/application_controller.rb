class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def index
    # Website Root
  end
  
  # Granular control over devise sign in paths
  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      root_path
    else
      root_path      
    end
  end
end
