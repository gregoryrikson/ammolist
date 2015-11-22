module Spree
  class ShippingConstraint < Spree::Base
    belongs_to :constraint_type, class_name: 'Spree::ConstraintType'
    belongs_to :shipping_method, class_name: 'Spree::ShippingMethod'
  end
end
