module Spree
  class ShippingRate < Spree::Base
    belongs_to :shipment, class_name: 'Spree::Shipment'
    belongs_to :shipping_method, class_name: 'Spree::ShippingMethod', inverse_of: :shipping_rates
    belongs_to :tax_rate, class_name: 'Spree::TaxRate'

    delegate :order, :currency, to: :shipment
    delegate :name, to: :shipping_method

    attr_accessor :is_shipping_allowed
    attr_accessor :shipping_notallowed_msg

    def display_base_price
      Spree::Money.new(cost, currency: currency)
    end

    def calculate_tax_amount
      tax_rate.calculator.compute_shipping_rate(self)
    end

    def display_price
      price = display_base_price.to_s
      if tax_rate
        tax_amount = calculate_tax_amount
        if tax_amount != 0
          if tax_rate.included_in_price?
            if tax_amount > 0
              amount = "#{display_tax_amount(tax_amount)} #{tax_rate.name}"
              price += " (#{Spree.t(:incl)} #{amount})"
            else
              amount = "#{display_tax_amount(tax_amount*-1)} #{tax_rate.name}"
              price += " (#{Spree.t(:excl)} #{amount})"
            end
          else
            amount = "#{display_tax_amount(tax_amount)} #{tax_rate.name}"
            price += " (+ #{amount})"
          end
        end
      end
      price
    end
    alias_method :display_cost, :display_price

    def display_tax_amount(tax_amount)
      Spree::Money.new(tax_amount, currency: currency)
    end

    def shipping_method
      Spree::ShippingMethod.unscoped { super }
    end

    def shipping_method_code
      shipping_method.code
    end

    def shipping_allowance(total, constraint_type)
      shipping_allowance = {}
      shipping_method.shipping_constraints.each do |const|
        if const.constraint_type_id == constraint_type.id
          attribute = []
          if !const.min_value.blank? && total < const.min_value.to_i
            attribute << "#{constraint_type.name} (#{total} #{constraint_type.unit}) is smaller than minimum #{constraint_type.variant_column_name} limit (#{const.max_value} #{constraint_type.unit})"
          elsif !const.max_value.blank? && total > const.max_value.to_i
            attribute << "#{constraint_type.name} (#{total} #{constraint_type.unit}) is greater than maximum #{constraint_type.variant_column_name} limit (#{const.max_value} #{constraint_type.unit})"
          end
          unless attribute.empty?
            shipping_allowance[constraint_type.id] = attribute
          end
        end
      end
      shipping_allowance
    end

    def tax_rate
      Spree::TaxRate.unscoped { super }
    end
  end
end
