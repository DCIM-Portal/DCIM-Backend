$(document).on 'turbolinks:before-cache', ->
  #Load overlay and hide tables
  $('.overlay').show()
  $('#main_table_body').hide()
  $('#main_header').hide()
  #If we select any items in a datatable,
  #we must remove the selected attribute on reload
  $('tr').removeClass('selected')

