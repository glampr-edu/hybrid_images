# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end
  
  def crop_and_resize(max_width, filter)
    manipulate! do |img|
      crop_string = "#{model.crop_w}x#{model.crop_h}+#{model.crop_x}+#{model.crop_y}"
      img.crop(crop_string) if model.cropping?
      img.resize(max_width.to_s)
      Rails.logger.debug "filter == #{filter}"
      img.adaptive_blur       "10x5"          if filter == :blur
      img.unsharp             "10x2"          if filter == :sharpen
      img
    end
  end

  # Create different versions of your uploaded files:
  version :blurred do
    process :crop_and_resize => [400, :blur]
  end

  version :sharp do
    process :crop_and_resize => [400, :sharpen]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
