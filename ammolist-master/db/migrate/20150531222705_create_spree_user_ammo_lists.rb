class CreateSpreeUserAmmoLists < ActiveRecord::Migration
  def change
    create_table :spree_user_ammo_lists do |t|
      t.belongs_to :user
      t.string :ip_address
      t.string :email
      t.string :taxons_id
      t.string :applied_properties

      t.timestamps
    end
  end
end
