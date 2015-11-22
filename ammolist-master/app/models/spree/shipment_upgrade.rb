module Spree
  class ShipmentUpgrade < Spree::Base
    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method_upgrade, class_name: 'Spree::ShippingMethodUpgrade', inverse_of: :shipment_upgrades
    
    delegate :currency, to: :shipment

    before_save :calculated_cost

    def calculated_cost
      calculated_cost = shipping_method_upgrade.calculator(shipment)
      write_attribute(:cost, calculated_cost)
    end

    def display_cost
      Spree::Money.new(cost, currency: currency)
    end

  end
end