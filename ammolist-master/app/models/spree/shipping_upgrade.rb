module Spree
  class ShippingUpgrade < Spree::Base
    has_many :shipping_method_upgrades, :dependent => :destroy
    has_many :shipping_methods, through: :shipping_method_upgrades
  end
end
