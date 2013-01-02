module ApplicationHelper

  def title(page_title)
    content_for(:title) { "NetMetric MoM :: "+page_title }
  end

end
