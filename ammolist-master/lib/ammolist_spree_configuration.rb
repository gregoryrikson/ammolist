module Spree
  class AmmolistSpreeConfiguration < Spree::Preferences::Configuration
    preference :cms_id, :integer, :default => 1
    preference :top_taxons_number, :integer, :default => 35
  end
end