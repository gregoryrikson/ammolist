class CreateSpreeShippingMethodUpgrades < ActiveRecord::Migration
  def change
    create_table :spree_shipping_method_upgrades do |t|
      t.belongs_to :shipping_method
      t.belongs_to :shipping_upgrade
      t.decimal :calculated_value, :precision => 8, :scale => 2, :default => 0.0

      t.timestamps
    end
  end
end
