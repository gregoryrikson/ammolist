window.replace_checkout_step = (step, partial, error) ->
  disable_steps true
  step.html(partial) if partial?
  step.find('form.edit_order').prepend("<p class='checkout-error'>#{error}</p>") if !!error
  enable_step step

enable_step = (element) ->
  element.show()
  element.removeClass("disabled-step")
  element.find("form input").removeAttr("disabled")
  element.find("#checkout-summary, .errorExplanation").show()
  ($ ".modal").hide()  
  Spree.onDeliverySelectShipping()
  Spree.onDeliverySelectUpgrade() 
  # Call Spree step specific javascript
  if Spree.isOnCartForm()
    Spree.hideDeliveryDivs() 
    Spree.onReloadCart()   
  if element.data('step') == 'address'
    Spree.onAddress()
  if element.data('step') == 'delivery'
    Spree.onDeliveryFormValidate() 
  if element.data('step') == 'payment'
    Spree.onPayment()

disable_steps = (all) ->
  elements = if all? then ($ ".checkout_content") else ($ ".checkout_content.disabled-step")
  elements.addClass("disabled-step")
  elements.find("form input").attr("disabled", "disabled")
  elements.hide()
  elements.find("#checkout-summary, .errorExplanation").hide()

Spree.ready ($) ->
  if ($ '#checkout').is('*')
    disable_steps()

Spree.ready ($) ->
  ($ document).on "ajax:beforeSend", "#checkout form[data-remote=true]", ->
    $('html, body').animate { scrollTop: 0 }, 'slow'
    ($ ".modal").show()