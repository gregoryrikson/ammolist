module Spree
  module Admin
    class ProductPropertiesController < ResourceController
      belongs_to 'spree/product', :find_by => :slug
      before_action :find_properties
      before_action :find_all_product_properties
      before_action :setup_property, only: :index

      private
        def find_properties
          @properties = Spree::Property.pluck(:name)
        end

        def find_all_product_properties
          @product_properties_data = Hash.new { |hash, key| hash[key] = [] }
          @properties.each do |p|
            product_property = Spree::Property.find_by(name: p)
            @product_properties_data[p] = Spree::ProductProperty.where(property_id: product_property.id).pluck(:value).uniq.map(&:to_s)
          end
        end

        def setup_property
          @product.product_properties.build
        end
    end
  end
end
