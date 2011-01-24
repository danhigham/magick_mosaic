require 'RMagick'
require 'open-uri'

class MosaicController < ApplicationController
  
  def index

    if request.post?
      respond_to do |format|
        format.json {
          
          render :text => mosaic(params[:images], params["scale-to-width"].to_i, params["scale-to-height"].to_i)
        }        
      end
    else
      
    end


    
  end

  def tryout
    
  end


  def mosaic(images, width, height)
    image_stack = Array.new
    rotation = 0
        
    images.each do |image|
      if (!image.empty?)
        rotation += 7
      
        buffer = open(image).read
        img = Magick::Image.from_blob(buffer).first
      
        img = polaroid_effect(img, rotation)
        image_stack << img    
      end
    end
    
    img = composite_stack(image_stack, -(rotation / 2), width, height)
    
    tempfile = Tempfile.new('out')
    path = "#{tempfile.path}.png"
    img.write(path) { self.quality = 100 }
    
    return path     
  end
  
  private 
  
  def polaroid_effect(image, rotation)
    image.border!(8, 8, "#f0f0ff")
    image.border!(1, 1, "#a9a9a9")

    # Bend the image
    image.background_color = "none"

    #amplitude = image.columns * 0.01        # vary according to taste
    #wavelength = image.rows  * 2

    #image.rotate!(90)
    #image = image.wave(amplitude, wavelength)
    #image.rotate!(-90)

    # Make the shadow
    #shadow = image.flop
    #shadow = shadow.colorize(1, 1, 1, "gray75")     # shadow color can vary to taste
    #shadow.background_color = "transparent"       # was "none"
    #shadow.border!(10, 10, "transparent")
    #shadow = shadow.blur_image(0, 3)        # shadow blurriness can vary according to taste

    # Composite image over shadow. The y-axis adjustment can vary according to taste.
    #image = shadow.composite(image, -amplitude/2, 5, Magick::OverCompositeOp)

    rotation_angle = rotation || (rand(10) - rand(10)) # random angle

    image.rotate!(rotation_angle)                       # vary according to taste
    image.trim!
    
    image
  end
  
  def composite_stack(image_stack, rotation, width, height)
    base_image = Magick::Image.new(1000,1000) {
      self.background_color = "none"
    }
    
    image_stack.each do |image|
      #x = rand(200 - image.columns)
      #y = rand(200 - image.rows)
      
      x = y = 0
      
      base_image.composite!(image, x, y, Magick::OverCompositeOp)
    end
    base_image.rotate!(rotation)
    base_image.trim!
    base_image.resize_to_fit(width,height)
  end

end
