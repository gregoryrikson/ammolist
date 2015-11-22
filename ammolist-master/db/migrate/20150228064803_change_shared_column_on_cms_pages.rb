class ChangeSharedColumnOnCmsPages < ActiveRecord::Migration
  def change
  	change_column :comfy_cms_pages, :is_shared, :boolean, :null => false, :default => true
  end
end
