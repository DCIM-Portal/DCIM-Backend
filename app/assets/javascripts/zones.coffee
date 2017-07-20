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

$(document).on 'turbolinks:before-cache', ->
  #Hide zone table
  $('#zone_table').DataTable().destroy()
