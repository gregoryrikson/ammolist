class CreateComfyCmsSharedMedia < ActiveRecord::Migration
  def change
    create_table :comfy_cms_shared_media do |t|
      t.integer :site_id,     :null => false
      t.string :name,     :null => false
      t.string :info
      t.string :logo_url
      t.boolean :is_active,   :null => false, :default => true

      t.timestamps
    end
  end
end
