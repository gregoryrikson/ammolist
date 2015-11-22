window.replace_delivery_part = (elem, partial) ->
  elem.html(partial) if partial?
  Spree.onDeliverySelectShipping()
  Spree.onDeliverySelectUpgrade() 

Spree.ready ($) ->
  Spree.onDeliveryFormValidate = () ->
    ($ '#checkout_form_delivery').validate()
  Spree.onDeliveryFormValidate()

Spree.isOnDeliveryCheckoutForm = () ->
  onCheckoutForm = $('html, body').find("#checkout, #checkout_delivery")
  onCheckoutForm.length

Spree.ready ($) ->
  Spree.onDeliverySelectShipping = () -> 
    $('.shipping-method input[type=radio]').on 'change', ->
      form_id = $(this).data("shipment-form-id")
      elem = $('#shipping_upgrade_'+form_id+' .shipping-upgrade input[type=checkbox]')
      $.ajax
        type: 'POST'
        data: 
          shipment_id: $(this).data("shipment-id")
          shipment_form_id: form_id
          selected_shipping_rate_id: $(this).val()
        dataType: 'script'
        url: Spree.url(Spree.routes.checkout_delivery)
        beforeSend: -> 
          elem.attr("disabled", "disabled")
        success: (data) ->
          Spree.onDeliverySelectUpgrade()          
          if Spree.isOnCartForm()
            Spree.onReloadCart()
          else if Spree.isOnDeliveryCheckoutForm()
            Spree.onReloadSummary()
          return true
      false
  Spree.onDeliverySelectShipping()

Spree.ready ($) ->
  Spree.onDeliverySelectUpgrade = () -> 
    $('.shipping-upgrade input[type=checkbox]').on 'change', ->
      $.ajax
        type: 'POST'
        data: 
          shipment_id: $(this).data("shipment-id")
          selected_shipping_upgrade_id: $(this).val()
          selected_shipping_upgrade_status: $(this).is(":checked")
        dataType: 'script'
        url: Spree.url(Spree.routes.update_shipment_upgrade)
        success: (data) ->
          if Spree.isOnCartForm()
            Spree.onReloadCart()
          else if Spree.isOnDeliveryCheckoutForm()
            Spree.onReloadSummary()
          true
      false
  Spree.onDeliverySelectUpgrade()

Spree.ready ($) ->
  Spree.onReloadSummary = () ->
    $.ajax
      type: 'POST'
      dataType: 'script'
      url: Spree.url(Spree.routes.checkout_summary)
      beforeSend: -> 
        ($ ".modal-summary").show()
      success: (data) ->
        ($ ".modal-summary").hide()
        return true