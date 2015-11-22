class Comfy::Cms::SharedMediaKey < ActiveRecord::Base
  self.table_name = 'comfy_cms_shared_media_keys' 
  # -- Relationships --------------------------------------------------------
  belongs_to :shared_media, class_name: "Comfy::Cms::SharedMedia"
end
