class CreateAmmolistTaxonCalibers < ActiveRecord::Migration
  def change
    create_table :ammolist_taxon_calibers do |t|
      t.integer :taxon_id
      t.integer :point

      t.timestamps
    end
  end
end
