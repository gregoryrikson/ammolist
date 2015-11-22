module Spree
  module Stock
    class AvailabilityValidator < ActiveModel::Validator
      def validate(line_item)
        unit_count = line_item.inventory_units.size
        return if unit_count >= line_item.quantity
        quantity = line_item.quantity - unit_count
        return if quantity.zero?

        quantifier = Stock::Quantifier.new(line_item.variant)

        return if quantifier.can_supply?(quantity)

        variant = line_item.variant
        display_name = "#{variant.name}"
        display_name += " (#{variant.options_text})" unless variant.options_text.blank?

        total_on_hand_info =  "#{quantifier.total_on_hand}"
        if quantifier.total_on_hand == 1
          total_on_hand_info += " unit"
        else
          total_on_hand_info += " units"
        end

        line_item.errors[:quantity] << Spree.t(
          :selected_quantity_not_available,
          item: display_name.inspect,
          total_on_hand: total_on_hand_info
        )
      end
    end
  end
end
