$(document).on 'turbolinks:load', ->

  #BmcScanRequest main table
  bmc_scan_table = $('#bmc_scan_table').DataTable
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
      { "data": "start_address" },
      { "data": "end_address" },
      { "data": "status" },
      { "data": "brute_list" },
      { "data": "zone" },
      { "data": "created_at" },
      { "data": "url" }
    ]
    deferRender: true
    order: [ 0, 'asc' ]
    responsive: true
    columnDefs: [
      { targets: 7
      data: 7
      render: (data, type, full, meta) ->
        moment(data).format 'MMMM D YYYY, h:mma'
      }
      { targets: 8
      orderable: false 
      render: (data, type, full, meta) ->
        '<a class="btn btn-info btn-sm" href="' + data + '">Details</a>'
      }
    ]
    drawCallback: ->
      $('.overlay').hide()

  #BmcScanRequest Host List Table
  bmc_host_scan_table = $('#bmc_host_scan_table').DataTable
    ajax: {
      url: window.location.href
      type: 'GET'
      dataSrc: "bmc_hosts"
      beforeSend: (request) ->
        request.setRequestHeader 'Accept', 'application/json'
    }
    columns: [
      { "data": "ip_address" },
      { "data": "system_model" },
      { "data": "serial" },
      { "data": "power_status" },
      { "data": "scan_status" },
      { "data": "is_discovered" },
      { "data": "updated_at" }
    ]
    deferRender: true
    order: [ 0, 'asc' ]
    dom: '<"top clearfix"lf><"middle"B><t><"bottom"ip><"clearfix">'
    select: 'os'
    buttons: [
      {
        text: '<i class="fa fa-check-square"></i> <span class="dt-btn-text">Select All</span>'
        action: ->
          bmc_host_scan_table.rows( { search: 'applied' } ).select()
        className: 'btn grey lighten-2 waves-effect'
      }
      {
        text: '<i class="fa fa-window-close"></i> <span class="dt-btn-text">Select None</span>'
        action: ->
          bmc_host_scan_table.rows().deselect()
        className: 'btn grey lighten-2 waves-effect'
      }
      {
        extend: 'copyHtml5'
        text:  '<i class="fa fa-clipboard"></i> <span class="dt-btn-text">Copy to Clipboard</span>'
        exportOptions: rows: '.selected'
        className: 'btn grey lighten-2 waves-effect'
      }
      {
        extend: 'csvHtml5'
        text: '<i class="fa fa-file-text"></i> <span class="dt-btn-text">Save to Excel</span>'
        exportOptions: rows: '.selected'
        className: 'btn grey lighten-2 waves-effect'
      }
    ]
    columnDefs: [
      { targets: 6
      data: 6
      render: (data, type, full, meta) ->
        moment(data).format 'MMMM D YYYY, h:mma'
      },
      { targets: 3
      data: 3
      render: (data, type, full, meta) ->
        if data == "on"
          '<div class="power_status green lighten-2 z-depth-1"><i class="fa fa-power-off"></i> On</div>'
        else if data == "off"
          '<div class="power_status red lighten-2 z-depth-1"><i class="fa fa-power-off"></i> Off</div>'
        else
          data
      width: 50
      },
      { targets: 1
      data: 1
      render: (data, type, full, meta) ->
        if /(HP)/.test(data)
          '<div class="model_wrapper"><div class="img-box"><img src="/images/hpe.png" height=25 width=57 /></div><div class="model_cell">' + data + '</div></div>'
        else if /(Cisco)/.test(data)
          '<div class="model_wrapper"><div class="img-box"><img src="/images/cisco.png" height=25 width=45 /></div><div class="model_cell">' + data + '</div></div>'
        else if /(DELL)/.test(data)
          '<div class="model_wrapper"><div class="img-box"><img src="/images/dell.png" height=17 width=57 /></div><div class="model_cell">' + data + '</div></div>'
        else if /(IBM)/.test(data)
          '<div class="model_wrapper"><div class="img-box"><img src="/images/ibm.png" height=17 width=43 /></div><div class="model_cell">' + data + '</div></div>'
        else if /(Supermicro)/.test(data)
          '<div class="model_wrapper"><div class="img-box"><img src="/images/supermicro.png" height=25 width=43 /></div><div class="model_cell">' + data + '</div></div>'
        else
          '<div class="model_cell">' + data + '</div>'
      },
      { targets: 2
      data: 2
      render: (data, type, full, meta) ->
        '<div style="font-weight: 600">' + data + '</div>'
      width: 115
      }
      { targets: 0
      width: 75
      }
    ]
    responsive: true
    drawCallback: ->
      $('.overlay').hide()


$(document).on 'turbolinks:before-cache', ->
  #Destroy datatables to avoid wrapper duplication 
  $('#bmc_scan_table').DataTable().destroy()
  $('#bmc_host_scan_table').DataTable().destroy()
