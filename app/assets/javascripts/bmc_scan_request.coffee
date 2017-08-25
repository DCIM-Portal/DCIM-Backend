$(document).on 'turbolinks:load', ->

  document.render.detail_table.bmc_scan_request = (view) ->
    #BmcScanRequest main table
    document.detail_table_selector = '#bmc_scan_requests_table'
    document.detail_table = $(document.detail_table_selector).dataTable
      processing: true
      serverSide: true
      searching: true
      deferLoading: 0
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].bmc_scan_request = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.bmc_scan_request.data)
        return undefined
      lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      ajax: {
        url: $(document.detail_table_selector).data('source')
        data: (d) ->
          if $('#filters').length
            return $.extend {}, $('#filters').serializeObject(), d
          else if document.datatables_state_cache[document.href]?.bmc_scan_request?.filters?
            return $.extend {}, $(document.datatables_state_cache[document.href]?.bmc_scan_request?.filters).serializeObject(), d
          return d
      }
      columns: [
        { "data": "id" },
        { "data": "name" },
        { "data": "start_address" },
        { "data": "end_address" },
        { "data": "status" },
        { "data": "cred_list" },
        { "data": "zone" },
        { "data": "updated_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><"middle"<"f_toolbar">><tr><"bottom"ip><"clearfix">'
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
        searchable: false
        render: (data, type, full, meta) ->
          if !data
            '<div class="blue-grey darken-2 white-text z-depth-1 sync"><i class="fa fa-hourglass-start" aria-hidden="true"></i> Queued</div>'
          else if data == "scan_complete"
            '<div class="green lighten-2 white-text z-depth-1 sync">Scan Complete</div>'
          else if data == "in_progress"
            '<div class="blue lighten-2 white-text z-depth-1 sync">Scan in progress <div class="throbber-loader"></div></div>'
          else
            '<div class="red lighten-2 white-text z-depth-1 sync">' + data + '</div>'
        }
        { targets: 8
        searchable: false
        orderable: false
        }
        { targets: 0
        width: 50 
        }
      ]
  
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
  
  document.render.detail_table.bmc_scan_request.bmc_host = (view) ->
    document.detail_table_selector = '#bmc_scan_request_details_table'
    #BmcScanRequest Host List Table
    document.detail_table = $(document.detail_table_selector).dataTable
      processing: true
      serverSide: true
      searching: true
      deferLoading: 0
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].bmc_host = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.bmc_host.data)
        return undefined
      lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
      ajax: {
        url: $(document.detail_table_selector).data('source')
        data: (d) ->
          if $('#filters').length
            return $.extend {}, $('#filters').serializeObject(), d
          else if document.datatables_state_cache[document.href]?.bmc_host?.filters?
            return $.extend {}, $(document.datatables_state_cache[document.href]?.bmc_host?.filters).serializeObject(), d
          return d
      }
      columns: [
        {data: 'checkbox'}
        {data: 'ip_address'}
        {data: 'brand'}
        {data: 'product'}
        {data: 'serial'}
        {data: 'power_status'}
        {data: 'sync_status'}
        {data: 'onboard_request_status'}
        {data: 'onboard_request_step'}
        {data: 'updated_at'}
        {data: 'url'}
      ]
      deferRender: true
      order: [ 1, 'asc' ]
      dom: '<"top clearfix"lf><"middle"B<"f_toolbar">><tr><"bottom"ip><"clearfix">'
      select: 'multi'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(1)').attr 'data-title', 'BMC Address:'
        $(row).find('td:eq(2)').attr 'data-title', 'Brand:'
        $(row).find('td:eq(3)').attr 'data-title', 'Product:'
        $(row).find('td:eq(4)').attr 'data-title', 'Serial:'
        $(row).find('td:eq(5)').attr 'data-title', 'Power Status:'
        $(row).find('td:eq(6)').attr 'data-title', 'Last Sync Status:'
        $(row).find('td:eq(7)').attr 'data-title', 'Onboard Status:'
        $(row).find('td:eq(8)').attr 'data-title', 'Synchronize Date:'
      buttons: [
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
        { targets: 0
        checkboxes: {
          selectRow: true
          }
        }
        { targets: 10
        orderable: false
        }
        { targets: 8
        orderable: false
        visible: false
        searchable: false
        }
        { targets: 7
        render: (data, type, full) ->
          if !data
            '<div class="blue-grey lighten-1 white-text z-depth-1 sync"><i class="fa fa-minus-circle" aria-hidden="true"></i> Not Onboarded</div>'
          else if data == "success"
            '<div class="green lighten-2 white-text z-depth-1 sync"><i class="fa fa-check-circle-o" aria-hidden="true"></i> '  + I18n.t(data, scope: 'filters.options.onboard_request.status') + ': ' + I18n.t(full.onboard_request_step, scope: 'filters.options.onboard_request.step') + '</div>'
          else if data == "in_progress"
            '<div class="blue lighten-2 white-text z-depth-1 sync"><i class="fa fa-refresh fa-spin fa-fw" aria-hidden="true"></i>' + I18n.t(data, scope: 'filters.options.onboard_request.status') + ': ' + I18n.t(full.onboard_request_step, scope: 'filters.options.onboard_request.step') + '</div>'
          else
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.onboard_request.status') + ': ' + I18n.t(full.onboard_request_step, scope: 'filters.options.onboard_request.step') + '</div>'
        }
        { targets: 5
        render: (data, type, full, meta) ->
          if data == "on"
            '<div class="power_status green lighten-2 z-depth-1"><i class="fa fa-power-off"></i> On</div>'
          else if data == "off"
            '<div class="power_status red lighten-2 z-depth-1"><i class="fa fa-power-off"></i> Off</div>'
          else
            '<div class="black-text">N/A</div>'
        width: 50
        }
        { targets: 6
        render: (data, type, full) ->
          if !data
            '<div class="blue-grey darken-2 white-text z-depth-1 sync"><i class="fa fa-hourglass-start" aria-hidden="true"></i> Queued</div>'
          else if data == "success"
            '<div class="green lighten-2 white-text z-depth-1 sync"><i class="fa fa-check-circle-o" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
          else if /(invalid)/.test(data)
            '<div class="orange lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
          else if data == "in_progress"
            '<div class="blue lighten-2 white-text z-depth-1 sync"><i class="fa fa-refresh fa-spin fa-fw" aria-hidden="true"></i> Syncing</div>'
          else
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
        width: 200
        }
        { targets: 2
        orderable: true
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
          else if !data
            '<div class="model_cell">N/A</div>'
          else
            '<div class="model_cell">' + data + '</div>'
        width: 175
        }
        { targets: 4
        orderable: true
        render: (data, type, full, meta) ->
          if data
            '<div class="serial">' + data + '</div>'
          else
            '<div class="serial">N/A</div>'
        width: 115
        }
        { targets: 1
        width: 75
        }
      ]
