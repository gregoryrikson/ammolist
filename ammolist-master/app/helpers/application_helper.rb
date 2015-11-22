module ApplicationHelper
    
  def taxons_tree_defined(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    root_taxon.children.map do |taxon|
      content_tag :li, class: 'js-topic' do
        content_tag(:h3, content_tag(:a, content_tag(:i, '', class: 'icon-right-open'), class: 'js-expand-btn collapsed toggle-advanced-menu')+
        link_to(taxon.name, seo_url(taxon))) +
        content_tag(:ul, taxons_tree_defined_children(taxon, current_taxon, max_level - 1), class: 'js-guides')
      end
    end.join("\n").html_safe
  end

  def taxons_tree_defined_children(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    root_taxon.children.map do |taxon|
      if taxon.children.empty?
        content_tag :li do
          content_tag(:i, '', class: 'icon-dot') +
          link_to(taxon.name, seo_url(taxon)) +
          content_tag(:div, '', class: 'toc')
        end
      else
        content_tag :li, class: 'js-topic' do
          content_tag(:i, '', class: 'icon-right-open') +
          link_to(taxon.name, seo_url(taxon)) +
          content_tag(:ul, taxons_tree_defined_children(taxon, current_taxon, max_level - 1), class: 'js-guides')
        end
      end
    end.join("\n").html_safe
  end

  def taxons_tree_nav(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    sorted_taxon_children = sort_taxon_by_first_number(root_taxon.children)
    sorted_taxon_children.map do |taxon|
      if taxon.children.empty?
        content_tag :li do
          link_to(taxon.name, seo_url(taxon))
        end
      else
        content_tag :li do
          link_to(taxon.name, seo_url(taxon)) +
          content_tag(:ul, taxons_tree_nav(taxon, current_taxon, max_level - 1), class: "arrow_nav")
        end
      end
    end.join("\n").html_safe
  end

  def taxons_category_nav(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.children.empty?
    sorted_taxon_children = sort_main_taxon_by_list(root_taxon.children)
    sorted_taxon_children.map do |taxon|
      content_tag :li do
        link_to(taxon.name, seo_url(taxon))
      end
    end.join("\n").html_safe
  end

  def display_price_per_round(product_or_variant, quantity)
    per_round = product_or_variant.amount_in(current_currency) / quantity.to_i
    # Spree::Money.new(per_round).to_html
    # if per_round > 1
    #   Spree::Money.new("%.3f" % per_round).to_html
    # else
      ("$"+("%.4f" % (per_round))).to_html
    # end
  end

  def update_ammolist_taxon_caliber(taxon_id)
    if AmmolistTaxonCaliber.exists?(:taxon_id => taxon_id)
      @ammolist_taxon_caliber = AmmolistTaxonCaliber.find_by(:taxon_id => taxon_id)
      @ammolist_taxon_caliber.point += 1
      @ammolist_taxon_caliber.save
    else
      @ammolist_taxon_caliber = AmmolistTaxonCaliber.new
      @ammolist_taxon_caliber.taxon_id = taxon_id
      @ammolist_taxon_caliber.point = 1
      @ammolist_taxon_caliber.save
    end
  end

  def sort_taxon_by_first_number(objects)
    regex = /\d{1,5}/
    new_objects = objects.sort_by{|obj| obj.name[regex].to_i }
    new_objects
  end

  def sort_main_taxon_by_list(objects)
    list = ["RIMFIRE", "SHOTGUN", "HANDGUN", "RIFLE"]

    # sort by index in the list. If not found - put as last.
    objects.sort_by { |e| list.index(e[:name]) || list.length } 
  end

  def taxon_has_instock_products(taxon)
    taxon.products.each do |product|
      if product.master.can_supply? && product.master.total_on_hand > 0
        return true
      end
    end
    false
  end  

  def header_embedded_script
    site_id = Ammolist::Config[:cms_id]
    @site = Comfy::Cms::Site.find_by_id(site_id)
    # get properties layout id 9 "Spree Header Embedded"
    @site.pages.published.where(:layout_id => 9)
  end
end