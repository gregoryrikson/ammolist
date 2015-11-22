Spree.ready ($) ->
  Spree.onUpdateQuantity = () ->
    $('.qtyplus').click (e) ->
      # Stop acting like a button
      e.preventDefault()
      # Get the field name
      fieldName = $(this).attr('field')
      # Get its current value
      currentVal = parseInt($('input[name=\'' + fieldName + '\']').val())
      # If is not undefined
      if !isNaN(currentVal)
        # Increment
        $('input[name=\'' + fieldName + '\']').val currentVal + 1
      else
        # Otherwise put a 0 there
        $('input[name=\'' + fieldName + '\']').val 0
      ($ this).parents('form').first().submit()
      return
    # This button will decrement the value till 0
    $('.qtyminus').click (e) ->
      # Stop acting like a button
      e.preventDefault()
      # Get the field name
      fieldName = $(this).attr('field')
      # Get its current value
      currentVal = parseInt($('input[name=\'' + fieldName + '\']').val())
      # If it isn't undefined or its greater than 0
      if !isNaN(currentVal) and currentVal > 0
        # Decrement one
        $('input[name=\'' + fieldName + '\']').val currentVal - 1
      else
        # Otherwise put a 0 there
        $('input[name=\'' + fieldName + '\']').val 0
      ($ this).parents('form').first().submit()
      return
  Spree.onUpdateQuantity()