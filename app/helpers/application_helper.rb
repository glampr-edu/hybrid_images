module ApplicationHelper
  
  def link_to_image(object, method, extra = {})
    image_url     = object.send(method).try(:url)
    image_options = {:height => 50}.merge(extra[:image] || {})
    link_options  = {:target => "_blank"}.merge(extra[:link] || {})
    link_to_if image_url, image_tag(image_url, image_options), extra[:href] || image_url, link_options do "" end
  end
  
end
