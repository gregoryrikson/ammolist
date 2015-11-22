//= require jquery.validate/jquery.validate.min
//= require spree
//= require spree/frontend/one_page_checkout
//= require spree/frontend/checkout
//= require spree/frontend/product
//= require spree/frontend/cart
//= require spree/frontend/cart_shipping
//= require spree/frontend/cart_items
//= require spree/backend/spree-select2
//= require datatables/jquery.dataTables.min
//= require datatables/dataTables.jqueryui
//= require magnific-popup
//= require slicknav/jquery.slicknav.min
//= require responsive-nav
//= require jquery-dropdown/jquery.dropdown.min
//= require spree/frontend/checkout/delivery
//= require jquery-circle-progress/circle-progress
//= require spree/frontend/field_increment
//= require spree/countdown/jquery.countdownTimer
//= require spree/custom
//= require spree/home

Spree.routes.taxon_all_products = Spree.pathFor('taxons/all_products')
Spree.routes.taxons_products = Spree.pathFor('taxons/taxons_products')
Spree.routes.taxon_update_point = Spree.pathFor('taxons/taxon_update_point')
Spree.routes.update_user_ammolist = Spree.pathFor('taxons/taxon_update_user_ammolist')
Spree.routes.subscribe_user_ammolist = Spree.pathFor('taxons/taxon_subscribe_user_ammolist')
Spree.routes.get_user_ammolist = Spree.pathFor('taxons/taxon_get_user_ammolist')
Spree.routes.email_subscribe = Spree.pathFor('subscriptions/subscribe')
Spree.routes.cart = Spree.pathFor('cart')
Spree.routes.checkout_delivery = Spree.pathFor('checkout/update_delivery')
Spree.routes.update_shipment_upgrade = Spree.pathFor('checkout/update_shipment_upgrade')
Spree.routes.checkout_summary = Spree.pathFor('checkout/summary')



