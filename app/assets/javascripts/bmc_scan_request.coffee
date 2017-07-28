$(document).on 'turbolinks:load', ->

  document.render.detail_table.bmc_scan_request = (view) ->
    #BmcScanRequest main table
    document.detail_table = $('#bmc_scan_requests_table').DataTable
      data: view
      rowId: 'id'
      columns: [
        { "data": "id" },
        { "data": "name" },
        { "data": "start_address" },
        { "data": "end_address" },
        { "data": "status" },
        { "data": "brute_list.name" },
        { "data": "zone.name" },
        { "data": "created_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><t><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'Scan ID:'
        $(row).find('td:eq(1)').attr 'data-title', 'Scan Name:'
        $(row).find('td:eq(2)').attr 'data-title', 'Start Address:'
        $(row).find('td:eq(3)').attr 'data-title', 'End Address:'
        $(row).find('td:eq(4)').attr 'data-title', 'Scan Status:'
        $(row).find('td:eq(5)').attr 'data-title', 'Associated Cred List:'
        $(row).find('td:eq(6)').attr 'data-title', 'Datacenter Zone:'
        $(row).find('td:eq(7)').attr 'data-title', 'Scan Initiated:'
      deferRender: true
      order: [ 0, 'asc' ]
      columnDefs: [
        { targets: 4
        render: (data, type, full, meta) ->
          if data == "scan_complete"
            '<span class="badge green lighten-2">Scan Complete</span>'
          else if data == "in_progress"
            '<span class="badge blue lighten-2">Scan in progress <div class="throbber-loader"></div></span>'
          else
            '<span class="badge red lighten-2">' + data + '</span>'
        }
        { targets: 7
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
  
  document.render.category_table.bmc_scan_request = (record) ->
    for key, value of record
      $("#category_" + document.category_name + "_" + key).html(value)
      $(".category_" + document.category_name + "_" + key).html(value)
      if key == "status" && value == "in_progress"
        $("#category_" + document.category_name + "_" + key).html('<span class="badge blue lighten-2">Scan in progress <div class="throbber-loader"></div></span>')
        $('.action_button').prop('disabled', true);
        $('.action_button').addClass('disabled');
      else if key == "status" && value =="scan_complete"
        $("#category_" + document.category_name + "_" + key).html('<span class="badge green lighten-2">Scan Complete</span>')
        $('.action_button').prop('disabled', false);
        $('.action_button').removeClass('disabled');
      else if key == "status"
        $("#category_" + document.category_name + "_" + key).html('<span class="badge red lighten-2">' + value + '</span>')
        $('.action_button').prop('disabled', false);
        $('.action_button').removeClass('disabled');
      $("#category_" + document.category_name + "_brute_list_name").html(value.name) if key == "brute_list"
      $("#category_" + document.category_name + "_zone_name").html(value.name) if key == "zone"
      $("#category_" + document.category_name + "_updated_at").html(moment(value).format('MMM DD YYYY, h:mma')) if key == "updated_at"
  
  document.render.detail_table.bmc_host = (view) ->
    #BmcScanRequest Host List Table
    document.detail_table = $('#bmc_hosts_table').DataTable
      data: view
      rowId: 'id'
      columns: [
        { "data": "ip_address" },
        { "data": "system_model" },
        { "data": "serial" },
        { "data": "power_status" },
        { "data": "sync_status" },
        { "data": "is_discovered" },
        { "data": "updated_at" }
      ]
      deferRender: true
      order: [ 0, 'asc' ]
      dom: '<"top clearfix"lf><"middle"B><t><"bottom"ip><"clearfix">'
      select: 'os'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'BMC Address:'
        $(row).find('td:eq(1)').attr 'data-title', 'System Model:'
        $(row).find('td:eq(2)').attr 'data-title', 'Serial:'
        $(row).find('td:eq(3)').attr 'data-title', 'Power Status:'
        $(row).find('td:eq(4)').attr 'data-title', 'Last Sync Status:'
        $(row).find('td:eq(5)').attr 'data-title', 'Onboarded:'
        $(row).find('td:eq(6)').attr 'data-title', 'Synchronize Date:'
      buttons: [
        {
          text: '<i class="fa fa-check-square"></i> <span class="dt-btn-text">Select All</span>'
          action: ->
            document.detail_table.rows( { search: 'applied' } ).select() # TODO: Use `this`?
          className: 'btn grey lighten-2 waves-effect'
        }
        {
          text: '<i class="fa fa-window-close"></i> <span class="dt-btn-text">Select None</span>'
          action: ->
            document.detail_table.rows().deselect() # TODO: Use `this`?
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
        render: (data, type, full, meta) ->
          moment(data).format 'MMMM D YYYY, h:mma'
        }
        { targets: 3
        render: (data, type, full, meta) ->
          if data == "on"
            '<div class="power_status green lighten-2 z-depth-1"><i class="fa fa-power-off"></i> On</div>'
          else if data == "off"
            '<div class="power_status red lighten-2 z-depth-1"><i class="fa fa-power-off"></i> Off</div>'
          else
            '<div class="black-text">N/A</div>'
        width: 50 
        }
        { targets: 4
        render: (data, type, full, meta) ->
          if data == "success"
            '<div class="green lighten-2 white-text z-depth-1 sync"><i class="fa fa-check-circle-o" aria-hidden="true"></i> Successfully Synchronized</div>'
          else if data == "unknown_error"
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Unknown Error</div>'
          else if data == "unsupported_fru_error"
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Error - Unable to Collect System Info</div>'
          else if data == "invalid_password_error"
            '<div class="orange lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Error - Invalid Password</div>'
          else if data == "invalid_username_error"
            '<div class="orange lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Error - Invalid Username</div>'
          else if data == "invalid_credentials_error"
            '<div class="orange lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Error - Invalid Credentials</div>'
          else if data == "connection_timeout_error"
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> Error - Connection Timeout</div>'
          else if data == null
            '<div class="blue lighten-2 white-text z-depth-1 sync"><i class="fa fa-refresh fa-spin fa-fw" aria-hidden="true"></i> Currently Syncing</div>'
          else
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + data + '</div>'
        width: 200
        }
        { targets: 1
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
          else if data == null
            '<div class="model_cell">N/A</div>'
          else
            '<div class="model_cell">' + data + '</div>'
        width: 325
        }
        { targets: 2
        render: (data, type, full, meta) ->
          if data != null
            '<div class="serial">' + data + '</div>'
          else
            '<div class="serial">N/A</div>'
        width: 115
        }
        { targets: 0
        width: 75
        }
      ]
      drawCallback: ->
        $('.overlay').hide()
