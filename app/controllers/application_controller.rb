class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :set_charset
  
  def set_charset
    @headers["Content-Type"] = "text/html; charset=utf-8"
  end
end
