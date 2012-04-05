ActiveAdmin.register Image do
  
  filter :name
  filter :attachment
  filter :created_at

  config.clear_action_items!
  action_item :except => [:index] do
    link_to "List all images", images_path
  end
  action_item :except => [:new] do
    link_to "Upload new image", new_image_path
  end
  action_item :only => [:index] do
    link_to "Create hybrid image", blend_images_path
  end
  action_item :only => [:show] do
    link_to "Crop image", crop_image_path(resource)
  end
  action_item :except => [:index, :blend, :new] do
    link_to "Delete", image_path(resource), :method => :delete, :confirm => "Are u sure?"
  end
  
  index :as => :grid do |image|
    div do
      div do
        link_to_image(image, :attachment, :image => {:height => 200}, :href => image_path(image))
      end
      div do
        span { link_to "Blurred", select_for_hybrid_image_path(image, :version => "blurred"), :class => "status"}
        span { link_to "Sharp"  , select_for_hybrid_image_path(image, :version => "sharp")  , :class => "status"}
      end
    end
  end
  
  show do |image|
    panel "Image details" do
      attributes_table_for image do
        row :id
        row :name
        row :image do
          image_tag(image.attachment.url, :width => 800)
        end
        row :filtered_images do
          span { image_tag(image.attachment.url(:blurred)) }
          span { image_tag(image.attachment.url(:sharp)) }
        end
      end
    end
  end
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :attachment, :as => :file, :hint => link_to_image(f.object, :attachment)
      f.input :attachment_cache, :as => :hidden
    end
    f.buttons
  end
  
  member_action :crop do
    
  end
  
  member_action :select_for_hybrid do
    version           = ["blurred", "sharp"][["blurred", "sharp"].index(params[:version])] rescue version = nil
    session[version]  = resource.id if version
    redirect_to :back
  end
  
  collection_action :blend do
    redirect_to :back, :alert => "You have to select an image for the blurred part of the hybrid image" and return if session["blurred"].nil?
    redirect_to :back, :alert => "You have to select an image for the sharp part of the hybrid image" and return if session["sharp"].nil?
    blurred = Image.find_by_id(session["blurred"]).attachment.versions[:blurred].file.path
    sharp   = Image.find_by_id(session["sharp"]).attachment.versions[:sharp].file.path
    
    system            "mkdir -p public/hybrid"
    filename          = "#{session["blurred"]}-#{session["sharp"]}.jpg"
    output_file_path  = "public/hybrid/#{filename}"
    @hybrid_image_url = "/hybrid/#{filename}"
    
    blend_density     = (params[:density] || 50).to_i
    system            "composite #{sharp} #{blurred} -dissolve #{blend_density},100 #{output_file_path}"
  end
  
  sidebar "Useful links", :only => [:index] do
    ul do
      li { link_to "Example Matlab Code", "/example_matlab_code.html" }
      li { link_to "Powerpoint presentation", "/hybrid.pptx" }      
    end
  end
  
end
