Spree.ready ($) ->
  Spree.onCartShipping = () ->
    ($ '#shipping-cart-form').validate
      rules: 
        zipcode_name:
          required: true
  Spree.onCartShipping()

Spree.hideDeliveryDivs = () ->
  ($ ".progress-steps").hide()
  ($ ".stock-location").hide()
  ($ ".stock-contents").hide()
  ($ ".stock-shipping-method-title").hide()
  ($ "#customer-email").hide()
  #($ "fieldset#shipping_method").hide()
  ($ ".form-buttons").hide()
  ($ "#checkout-information").hide()
  ($ "#checkout_delivery_wrapper").removeClass("nine")
  ($ "#checkout_delivery_wrapper").addClass("twelve")
  false

Spree.isOnCartForm = () ->
  onCartForm = $('html, body').find("#cart_shipping_list")
  onCartForm.length

Spree.onSubmitZipcodeForm = () ->
  if ($ "#shipment_cost").length == 0
    if ($ "#order_bill_address_attributes_zipcode").val()
      ($ "#checkout_form_address").submit()
    else
      $( "#checkout_delivery" ).hide();

Spree.ready ($) ->
  ($ document).on "ajax:beforeSend", "#cart_shipping form[data-remote=true]", ->
    ($ ".modal").show()
