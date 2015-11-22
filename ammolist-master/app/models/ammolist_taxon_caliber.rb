class AmmolistTaxonCaliber < ActiveRecord::Base
		
  belongs_to :taxon, class_name: "Spree::Taxon"

  scope :by_point, -> { joins(:taxon).order("point DESC") }
end
