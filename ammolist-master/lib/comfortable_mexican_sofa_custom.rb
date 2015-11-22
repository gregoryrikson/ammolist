Dir.glob(File.expand_path('comfortable_mexican_sofa/tags/*.rb', File.dirname(__FILE__))).each do |path|
  require_relative path
end
