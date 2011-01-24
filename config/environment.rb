# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
MagickMosaic::Application.initialize!

#Register png response type
Mime::Type.register "image/png", :png