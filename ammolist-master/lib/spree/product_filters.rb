module Spree
  module Core
    module ProductFilters

    # Filtering by price
      Spree::Product.add_search_scope :price_range_any do |*opts|
        conds = opts.map {|o| Spree::Core::ProductFilters.price_filter[:conds][o]}.reject { |c| c.nil? }
        scope = conds.shift
        conds.each do |new_scope|
          scope = scope.or(new_scope)
        end
        Spree::Product.joins(master: :default_price).where(scope)
      end

      def ProductFilters.format_price(amount)
        Spree::Money.new(amount)
      end

      def ProductFilters.price_filter(products_searched = [])
        if products_searched.empty?
          v = Spree::Price.arel_table
          conds = [ [ Spree.t(:under_price, price: format_price(10))     , v[:amount].lteq(10)],
                    [ "#{format_price(10)} - #{format_price(20)}"        , v[:amount].in(10..20)],
                    [ "#{format_price(20)} - #{format_price(30)}"        , v[:amount].in(20..30)],
                    [ "#{format_price(30)} - #{format_price(40)}"        , v[:amount].in(30..40)],
                    [ Spree.t(:or_over_price, price: format_price(40)) , v[:amount].gteq(40)]]
        else
          products = Spree::Product.where(:id => [products_searched]).joins(master: :default_price)
          products_price = products.pluck(:amount)
          
          numbers_range = [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,9],[9,10]]
          tens_range = numbers_range.map { |n| n.map { |e| e*10 } }
          hundreds_range = numbers_range.map { |n| n.map { |e| e*100 } }
          thousands_range = numbers_range.map { |n| n.map { |e| e*1000 } }

          price_range = tens_range
          if products_price.max > 1000
            price_range = thousands_range
          elsif products_price.max > 100
            price_range = hundreds_range
          end 

          conds = []
          price_range.each do |p|
            scope = products.where("spree_prices.amount" => (p.first..p.last))
            count = scope.count
            if count > 0
              conds << ["#{format_price(p.first)} - #{format_price(p.last)}",  count]
            end
          end
        end
        {
          name:   Spree.t(:price_range),
          scope:  :price_range_any,
          conds:  Hash[*conds.flatten],
          labels: conds
        }
      end

      filters = Hash[:selective_quantity_any => 'Quantity',
                      :selective_manufacturer_any => 'Manufacturer',
                      :selective_use_type_any => 'Use Type',
                      :selective_bullet_type_any => 'Bullet Type',
                      :selective_bullet_weight_any => 'Bullet Weight',
                      :selective_ammo_casing_any => 'Ammo Casing',
                      :selective_ammo_caliber_any => 'Ammo Caliber',
                      :selective_primer_type_any => 'Primer Type',
                      :selective_condition_any => 'Condition'
                    ]
                    
      #Filtering Products              
      filters.each do |k,v|
        # Filtering by possible property
        Spree::Product.add_search_scope k do |*opts|
          conds = opts.map {|o| ProductFilters.filter(v, k)[:conds][o]}.reject { |c| c.nil? }
          scope = conds.shift
          conds.each do |new_scope|
            scope = scope.or(new_scope)
          end
          Spree::Product.with_property(v).where(scope)
        end
      end

      #Filtering menu
      def ProductFilters.filter(property_name = '', scope = nil)
        property = Spree::Property.find_by(name: property_name)
        product_properties = property ? Spree::ProductProperty.where(property_id: property.id).pluck(:value).uniq.map(&:to_s) : []
        pp = Spree::ProductProperty.arel_table
        conds = Hash[*product_properties.map { |b| [b, pp[:value].eq(b)] }.flatten]
        {
          name:   property_name,
          scope:  scope,
          conds:  conds,
          labels: (product_properties.sort).map { |k| [k, k] }
        }
      end

      def ProductFilters.selective_filter(property_name = '', selective_scope = nil, related_products = [])
        property = Spree::Property.find_by(name: property_name)
        scope = Spree::ProductProperty.where(property: property).
          where.not(:value => '')
        scope = scope.where(product: [related_products]) unless related_products.empty?
        product_properties = scope.pluck(:value).uniq
        product_properties_withcount = Hash.new { |hash, key| hash[key] = [] }
        product_properties.each do |p|
          count = scope.where(:value => p).count
          product_properties_withcount[p] = count
        end
        {
          name:   property_name,
          scope:  selective_scope,
          labels: product_properties_withcount.sort
        }
      end

      # Filtering by the list of all taxons
      #
      # Similar idea as above, but we don't want the descendants' products, hence
      # it uses one of the auto-generated scopes from Ransack.
      #
      # idea: expand the format to allow nesting of labels?
      def ProductFilters.all_taxons
        taxons = Spree::Taxonomy.all.map { |t| [t.root] + t.root.descendants }.flatten
        {
          name:   'All taxons',
          scope:  :taxons_id_equals_any,
          labels: taxons.sort_by(&:name).map { |t| [t.name, t.id] },
          conds:  nil # not needed
        }
      end

    end
  end
end
