class Comfy::Cms::SharedMedia < ActiveRecord::Base
  self.table_name = 'comfy_cms_shared_media'

  # -- Relationships --------------------------------------------------------
  belongs_to :site
  with_options :dependent => :destroy do |shared_media|
    shared_media.has_many :shared_media_keys, class_name: "Comfy::Cms::SharedMediaKey"
  end

  accepts_nested_attributes_for :shared_media_keys
end