class CreateComfyCmsPagesShares < ActiveRecord::Migration
  def change
    create_table :comfy_cms_pages_shares do |t|
      t.integer :page_id
      t.integer :shared_media_id
      t.boolean :is_shared

      t.timestamps
    end
  end
end
