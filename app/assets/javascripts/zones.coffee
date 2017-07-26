#Zones coffee scripts
$(document).on 'turbolinks:load', ->

  $('#async_wrapper').show()

  #Zones main table
  $('#zone_table').DataTable
    ajax: {
      url: window.location.href
      type: 'GET'
      dataSrc: ""
      beforeSend: (request) ->
        request.setRequestHeader 'Accept', 'application/json'
    }
    columns: [
      { "data": "id" },
      { "data": "name" },
      { "data": "created_at" },
      { "data": "url" }
    ]
    deferRender: true
    columnDefs: [
      { targets: 2
      render: (data, type, full, meta) ->
        moment(data).format 'MMMM D YYYY, h:mma'
      }
      { targets: 3
      orderable: false
      render: (data, type, full, meta) ->
        '<a class="btn btn-info btn-sm" href="' + data + '">Details</a>'
      }
      orderable: false
      targets: [1]
    ]
    order: [ 0, 'asc' ]
    responsive: true
    drawCallback: ->
      $('.overlay').hide()

$(document).on 'turbolinks:before-cache', ->
  #Hide zone table
  $('#zone_table').DataTable().destroy()
