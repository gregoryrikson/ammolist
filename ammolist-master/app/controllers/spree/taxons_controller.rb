module Spree
  class TaxonsController < Spree::StoreController
    include Spree::BaseHelper
    include ApplicationHelper
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionView::MissingTemplate, :with => :render_404
    helper 'spree/products'

    respond_to :html

    def show
      @taxon = Taxon.find_by_permalink!(params[:id])
      return unless @taxon

      @searcher = build_searcher(params.merge(taxon: @taxon.id, include_images: true))
      
      @products = @taxon.products.all

      if params[:search]
        params[:search].each do |k, v|
          @products &= @searcher.retrieve_products_with_scope(k)
        end
        unless @products
          @products = []
        end
      end

      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @applicable_filters = applicable_filters
    end
  
   def all_products
      taxon = Spree::Taxon.find(params[:id])
      @products = taxon.products
      product_list = []
      @products.each do |product|
        p = {}
        p['id'] = product.id
        p['name'] = product.name
        p['url'] = product_path(product)
        quantity = product.property('Quantity')
        p['price'] = '-'
        p['perround'] = '-'
        if display_price(product)
          p['price'] = display_price(product)
          if quantity && quantity.to_i > 0
            p['perround'] = display_price_per_round(product, quantity)
          end
        end
        product_list << p
      end
      respond_with(product_list) do |format|
        format.json {render :json => product_list }
      end
    end

    def taxons_products
      taxon = Spree::Taxon.where("spree_taxons.id in (?)", params[:id]).includes({:products => [:product_properties, :variants]}, :products => {:master => [:prices, :stock_items]})
      product_list = []
      properties = Spree::Property.all.map { |p| { p.id => p.name.downcase.strip.gsub(' ', '_')} }.reduce(:merge)
      taxon.each do |t|
        t.products.each do |product|
          p = {}
          p['taxon_id'] = t.id
          p['id'] = product.id
          p['master_id'] = product.master.id
          p['mini_img_url'] = view_context.mini_image(product)
          p['name'] = product.name
          p['url'] = product_path(product)
          # product properties
          product_properties = {}
          product_properties = product.product_properties.map { |e| {e.property_id => e.value} }.reduce(:merge)

          properties.each do |k, v|
            if product_properties
              p[v] = product_properties[k] || ""
            else
              p[v] = ""
            end
          end
          quantity = p['quantity']
          p['price'] = display_price(product) || '-'
          p['perround'] = '-'
          if display_price(product) && quantity && quantity.to_i > 0
           p['perround'] = display_price_per_round(product, quantity)
          end
          # in stock info
          in_stock = 1
          stock_count = 0
          backorderable = false
          product.master.stock_items.each do |item|
            stock_count += item.count_on_hand
            backorderable = true if item.backorderable
          end
          # if !product.master.can_supply? && (product.variants.empty? || product.master.total_on_hand == 0) 
          if !(stock_count >=1 or backorderable) && (product.variants.empty? || stock_count == 0) 
            in_stock = 0
          end
          p['in_stock'] = in_stock

          product_list << p
        end
      end
      respond_with(product_list) do |format|
        format.json {render :json => product_list }
      end
    end

    def taxon_product_info
      product = Spree::Product.find_by_id(params[:id])
      product_data = view_context.large_image(product)
      
      respond_with(product_data) do |format|
        format.html {render :text => product_data} 
      end
    end

    #update ammolist taxon caliber for top 30 caliber
    def taxon_update_point
      update_ammolist_taxon_caliber(params[:id])
      respond_to do |format|
        format.html
        format.js { render :json => "Updated Successfully" }
      end
    end

    def ip_address
      request.remote_ip
    end

    #update user ammolist
    def taxon_update_user_ammolist
      if params[:user_id] != ""
        if Spree::UserAmmoList.exists?(:user_id => params[:user_id])
          @user_ammolist = Spree::UserAmmoList.where(:user_id => params[:user_id]).last
          @user_ammolist.ip_address = ip_address
          @user_ammolist.email = params[:user_email]
          @user_ammolist.taxons_id = params[:selected_taxons]
          @user_ammolist.applied_properties = params[:applied_properties]
          @user_ammolist.save
        else
          @user_ammolist = Spree::UserAmmoList.new
          @user_ammolist.user_id = params[:user_id]
          @user_ammolist.ip_address = ip_address
          @user_ammolist.email = params[:user_email]
          @user_ammolist.taxons_id = params[:selected_taxons]
          @user_ammolist.applied_properties = params[:applied_properties]
          @user_ammolist.save
        end
      else
        if Spree::UserAmmoList.exists?(:ip_address => ip_address)
          @user_ammolist = Spree::UserAmmoList.where(:ip_address => ip_address).last
          @user_ammolist.taxons_id = params[:selected_taxons]
          @user_ammolist.applied_properties = params[:applied_properties]
          @user_ammolist.save
        else
          @user_ammolist = Spree::UserAmmoList.new
          @user_ammolist.ip_address = ip_address
          @user_ammolist.taxons_id = params[:selected_taxons]
          @user_ammolist.applied_properties = params[:applied_properties]
          @user_ammolist.save
        end
      end

      respond_to do |format|
        format.html { render :json => "User Ammolist Updated Successfully" }
      end
    end

    #subscribe user ammolist
    def taxon_subscribe_user_ammolist
      response_msg = []
      if params[:user_email].empty?
        response_msg = [ :status => 'error', :message => "You did not enter an email address" ]
      else
        @user_ammolist = Spree::UserAmmoList.new
        @user_ammolist.user_id = params[:user_id] if params[:user_id]
        @user_ammolist.ip_address = ip_address
        @user_ammolist.email = params[:user_email]
        @user_ammolist.taxons_id = params[:selected_taxons]
        @user_ammolist.applied_properties = params[:applied_properties]
        @user_ammolist.is_notified = true
        if @user_ammolist.save
          response_msg = [ :status => 'success', :message => "Data has been saved. Updated ammolist information will be sent." ]
        else
          response_msg = [ :status => 'error', :message => "Data can not be saved. Please try again later" ]
        end
      end
      
      respond_to do |format|
        format.js { render :json => response_msg }
      end    
    end

    #get user ammolist
    def taxon_get_user_ammolist
      ammolist = {}
      if params[:user_id] != ""
        if Spree::UserAmmoList.exists?(:user_id => params[:user_id])
          @user_ammolist = Spree::UserAmmoList.where(:user_id => params[:user_id]).last
          ammolist['taxons_id'] = @user_ammolist.taxons_id
          ammolist['applied_properties'] = @user_ammolist.applied_properties
        end
      else
        if Spree::UserAmmoList.exists?(:ip_address => ip_address)
          @user_ammolist = Spree::UserAmmoList.where(:ip_address => ip_address).last
          ammolist['taxons_id'] = @user_ammolist.taxons_id
          ammolist['applied_properties'] = @user_ammolist.applied_properties
        end
      end
      
      respond_to do |format|
        format.json { render :json => ammolist }
      end
    end

    private

    def accurate_title
      if @taxon
        @taxon.seo_title
      else
        super
      end
    end


    # indicate which filters should be used for a taxon
    def applicable_filters
      fs = []
      products_searched = []

      if params[:search] 
        if @products
          @products.each do |p|
            products_searched << p.id
          end
        end
      else
        products_searched = @taxon.products.all.pluck(:id)
      end

      fs << Spree::Core::ProductFilters.selective_filter('Quantity', :selective_quantity_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Manufacturer', :selective_manufacturer_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Use Type', :selective_use_type_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Bullet Type', :selective_bullet_type_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Bullet Weight', :selective_bullet_weight_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Ammo Casing', :selective_ammo_casing_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Ammo Caliber', :selective_ammo_caliber_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Primer Type', :selective_primer_type_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.selective_filter('Condition', :selective_condition_any, products_searched) if Spree::Core::ProductFilters.respond_to?(:selective_filter)
      fs << Spree::Core::ProductFilters.price_filter(products_searched) if Spree::Core::ProductFilters.respond_to?(:price_filter)
      fs
          
    end

  end
end
