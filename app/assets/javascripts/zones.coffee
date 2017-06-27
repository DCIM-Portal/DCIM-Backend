#Zones coffee scripts
$(document).on 'turbolinks:load', ->

  $('#async_wrapper').show()

  #Zones main table
  $('#zone_table').DataTable
    deferRender: true
    columnDefs: [ 
      orderable: false
      targets: [1,2]
    ]
    order: [ 0, 'asc' ]
    responsive: true
    drawCallback: ->
      $('#main_header').show()
      $('#main_table_body').show()
      $('.overlay').hide()

  #Hide success box on modal click
  $('#zone_modal').click ->
    $('#success_explanation').hide()

  #Editing a zone is AJAX call - display success
  $("form#zone_edit_ajax").on "ajax:success", (event, data, status, xhr) ->
    $("#waiting_explanation").hide()
    $("form.edit_zone")[0].reset()
    $("#zone_name").html(data.name)
    $(".zone_name").val(data.name)
    $("#success_explanation").show()
    $('.modal_error').hide()
    $('.zone-edit-button').removeClass('disabled')

  #Editing a zone is AJAX call - display error
  $("form#zone_edit_ajax").on "ajax:error", (event, xhr, status, error) ->
    $("#waiting_explanation").hide()
    errors = jQuery.parseJSON(xhr.responseText)
    $("#success_explanation").hide()
    $('.modal_error').empty()
    $('.modal_error').append('<ul>')
    for e in errors
      $('.modal_error ul').append('<li>' + e + '</li>')
    $('.modal_error').show()
    $('.zone-edit-button').removeClass('disabled')

$(document).on 'turbolinks:before-cache', ->
  #Hide zone table
  $('#zone_table').DataTable().destroy()
  $('#async_wrapper').hide()
  $("#success_explanation").hide()
  $('.modal_error').hide()
  $('#edit_zone').hide()
