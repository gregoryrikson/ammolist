class CreateSpreeShippingUpgrades < ActiveRecord::Migration
  def change
    create_table :spree_shipping_upgrades do |t|
      t.string :name
      t.string :description
      t.string :unit

      t.timestamps
    end
  end
end
