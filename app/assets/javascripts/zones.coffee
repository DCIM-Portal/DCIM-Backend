#Zones coffee scripts
$(document).on 'turbolinks:load', ->

  $('#async_wrapper').show()

  document.render.detail_table.zone = (view) ->
    #Zone Main Table
    document.detail_table = $('#zone_table').DataTable
      data: view
      rowId: 'id'
      columns: [
        { "data": "id" },
        { "data": "name" },
        { "data": "foreman_location_id" },
        { "data": "created_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><t><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'DCIM Zone ID:'
        $(row).find('td:eq(1)').attr 'data-title', 'Zone Name:'
        $(row).find('td:eq(2)').attr 'data-title', 'Foreman Zone ID:'
        $(row).find('td:eq(3)').attr 'data-title', 'Date Added:'
      deferRender: true
      columnDefs: [
        { targets: 3
        render: (data, type, full, meta) ->
          moment(data).format 'MMMM D YYYY, h:mma'
        }
        { targets: 4
        orderable: false
        render: (data, type, full, meta) ->
          '<a class="btn btn-info btn-sm" href="' + data + '">Details</a>'
        }
        orderable: false
        targets: [1]
      ]
      order: [ 0, 'asc' ]
      drawCallback: ->
        $('.overlay').hide()

  document.render.category_table.zone = (record) ->
    for key, value of record
      $("#category_" + document.category_name + "_" + key).html(value)
      $(".category_" + document.category_name + "_" + key).html(value)
      $("#category_" + document.category_name + "_updated_at").html(moment(value).format('MMM DD YYYY, h:mma')) if key == "updated_at"


$(document).on 'turbolinks:before-cache', ->
  #Hide zone table
  $('#zone_table').DataTable().destroy()
