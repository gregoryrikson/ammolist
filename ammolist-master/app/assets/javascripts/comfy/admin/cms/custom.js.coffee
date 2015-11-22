# Custom JS for the admin area

$(document).on 'page:load ready', ->
  CMS.page_update_share()

window.CMS.page_update_share = ->
  widget = $('#form-save2')
  $('input', widget).prop('checked', $('input#page_is_shared').is(':checked'))
  $('button', widget).html($('input[name=commit]').val())

  $('input', widget).click ->
    $('input#page_is_shared').prop('checked', $(this).is(':checked'))
  $('input#page_is_shared').click ->
    $('input', widget).prop('checked', $(this).is(':checked'))
  $('button', widget).click ->
    $('input[name=commit]').click()