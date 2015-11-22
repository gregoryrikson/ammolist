class AddShipmentUpgradesToShipments < ActiveRecord::Migration
  def up
    Spree::Shipment.find_each do |shipment|
      Spree::ShippingMethodUpgrade.find_each do |smu|
        shipment.shipment_upgrades.create(:shipping_method_upgrade_id => smu.id,
                                       :selected => false)
      end
    end
  end
end
