class Image < ActiveRecord::Base
  
  before_update  :do_crop
  
  mount_uploader :attachment, AttachmentUploader
  
  validates :name, :presence => true, :uniqueness => true
  validates :attachment, :presence => true
  
  def do_crop
    attachment.recreate_versions!
    true
  end
  
  def cropping?
    [crop_x, crop_y, crop_w, crop_h].map(&:to_i).sum != 0
  end
  
  def display_ratio(width = nil, height = nil)
    if width.nil? && height.nil?
      return 1
    elsif width && !width.zero?
      dimensions[:width] / width.to_f
    elsif heigth && !heigth.zero?
      dimensions[:heigth] / heigth.to_f
    else
      0
    end
  end
  
  def dimensions(style = :original)
    if (@dimensions.nil? || @dimensions[style].nil?)
      @dimensions ||= {}
      image = mini_magick_image(style)
      @dimensions[style] = {:width => image[:width], :height => image[:height]}
    end
    @dimensions[style]
  rescue
    {:width => 0, :height => 0}
  end
  
  def mini_magick_image(style = nil)
    filename = if (style && attachment.versions.keys.include?(style))
      attachment.versions[style].file.path
    else
      attachment.file.path
    end
    image = MiniMagick::Image.open(filename)
  end
  
end
