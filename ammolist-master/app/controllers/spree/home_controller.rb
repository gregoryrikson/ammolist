module Spree
  class HomeController < Spree::StoreController
    include Spree::BaseHelper
    include ApplicationHelper
    helper 'spree/products'
    respond_to :html

    def index
      @searcher = build_searcher(params.merge(include_images: true))
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
      @taxonomies_opt = taxonomies_filter

      site_id = Ammolist::Config[:cms_id]
      @site = Comfy::Cms::Site.find_by_id(site_id)
      # get properties layout id 2 "Spree Homepage Embedded"
      @properties = @site.pages.published.where(:layout_id => 2)
    end

    private

    def taxonomies_filter
      taxon_a = Hash.new { |hash, key| hash[key] = [] }
      
      taxon_a['TOP '+Ammolist::Config[:top_taxons_number].to_s] = AmmolistTaxonCaliber.by_point.map{ |t| t.taxon }

      filtered_taxon = ["RIMFIRE", "SHOTGUN", "HANDGUN", "RIFLE"]
      filtered_taxon.each do |taxon|
        @taxon_opt = Spree::Taxon.find_by_name(taxon)
        taxon_a[@taxon_opt.name] = sort_taxon_by_first_number(@taxon_opt.children)
      end

      taxon_a
    end

  end
end
