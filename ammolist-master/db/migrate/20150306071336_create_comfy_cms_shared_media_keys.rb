class CreateComfyCmsSharedMediaKeys < ActiveRecord::Migration
  def change
    create_table :comfy_cms_shared_media_keys do |t|
      t.integer :shared_media_id,    :null => false
      t.string :name,    :null => false
      t.string :value

      t.timestamps
    end
  end
end
