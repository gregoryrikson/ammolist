class CreateSpreeShipmentUpgrades < ActiveRecord::Migration
  def change
    create_table :spree_shipment_upgrades do |t|
      t.belongs_to :shipment
      t.belongs_to :shipping_method_upgrade
      t.boolean :selected, :default => false
      t.decimal :cost, :precision => 8, :scale => 2

      t.timestamps
    end
  end
end
