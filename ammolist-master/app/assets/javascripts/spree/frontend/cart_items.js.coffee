window.replace_line_items = (parent, partial) ->
  parent.html(partial) if partial?
  Spree.onUpdateCart()
  Spree.onUpdateQuantity()
  #Spree.onSubmitZipcodeForm()
  Spree.hideDeliveryDivs() 
  Spree.onDeliverySelectShipping()
  Spree.onDeliverySelectUpgrade() 
  Spree.fetch_cart()
  ($ ".modal").hide()

Spree.ready ($) ->
  Spree.onUpdateCart = () ->
    if ($ 'form#update-cart').is('*')
      ($ 'form#update-cart .line_item_quantity').on 'change', ->
        ($ this).parents('form').first().submit()
        false
  Spree.onUpdateCart()

Spree.onReloadCart = () ->
  $.ajax
    type: 'GET'
    dataType: 'script'
    url: Spree.url(Spree.routes.cart)
    beforeSend: -> 
      $('html, body').animate { scrollTop: 0 }, 'slow'
      ($ ".modal").show()
    success: (data) ->
      ($ ".modal").hide()
      true

Spree.ready ($) ->
  ($ document).on "ajax:beforeSend", "#cart_items form[data-remote=true]", ->
    ($ ".modal").show()
