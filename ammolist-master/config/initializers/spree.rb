# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'

require 'spree/product_filters'
require 'ammolist_spree_configuration'

Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false
  config.max_level_in_taxons_menu = 3

  # shipstation config
  config.shipstation_username = "munireusa"
  config.shipstation_password = "fart3278"
  config.shipstation_weight_units = "Pounds" # Grams, Ounces or Pounds
  # choose which number to send shipstation, use :shipment or :order, default is :shipment
  config.shipstation_number = :shipment
  # if you prefer to send notifications via shipstation
  config.send_shipped_email = false

  
  # From official documentation spree commerce
  attachment_config = {
    s3_credentials: {
      access_key_id:     'AKIAIKKLOYQNQ7JKOCIA',
      secret_access_key: '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',
      bucket:            'ammolist'
    },
    s3_headers: {
      "Cache-Control" => "max-age=31557600"
    },
    storage:        :s3,
    s3_protocol:    'https',
    s3_host_name:   's3-us-west-2.amazonaws.com',
    url:            '/spree/products/:id/:style/:basename.:extension',
    path:           '/spree/products/:id/:style/:basename.:extension'
  }

  attachment_config.each do |key, value|
    Spree::Image.attachment_definitions[:attachment][key.to_sym] = value
  end
  
end

Spree.user_class = "Spree::User"

config = Rails.application.config

config.spree.calculators.shipping_methods = [
      Spree::Calculator::Shipping::FlatPercentItemTotal,
      Spree::Calculator::Shipping::FlatRate,
      Spree::Calculator::Shipping::FlexiRate,
      Spree::Calculator::Shipping::PerItem,
      Spree::Calculator::Shipping::PriceSack,
      Spree::Calculator::Shipping::Fedex::Ground,
      Spree::Calculator::Shipping::Fedex::GroundHomeDelivery,
      Spree::Calculator::Shipping::Ups::Ground
    ]

config.spree.calculators.tax_rates = [
      Spree::Calculator::DefaultTax]

Ammolist::Config = Spree::AmmolistSpreeConfiguration.new
Ammolist::Config[:cms_id] = 1