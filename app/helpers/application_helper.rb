module ApplicationHelper
  
  # If we've defined a page title, use it, otherwise do something generic yet informative
  def get_page_title(controller)
    if @page_title == false
      @page_title = ""
    else
      @page_title = @page_title.blank? ? "&raquo; #{controller}".html_safe : "&raquo; #{@page_title}".html_safe
    end
  end
  
  # Dynamic Asset Packaging : CSS
  def get_asset_group_css
    @asset_group_css = @asset_group_css.blank? ? :common : @asset_group_css
  end
  
  # Dynamic Asset Packaging : JS
  def get_asset_group_js
    @asset_group_js = @asset_group_js.blank? ? :common : @asset_group_js
  end
  
end
