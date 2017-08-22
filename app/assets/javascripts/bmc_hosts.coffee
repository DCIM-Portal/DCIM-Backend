$(document).on 'turbolinks:load', ->

  document.render.detail_table.bmc_host = (view) ->
    document.detail_table_selector = '#bmc_hosts_table'
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
        {data: 'system_model'}
        {data: 'serial'}
        {data: 'zone_name'}
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
        $(row).find('td:eq(2)').attr 'data-title', 'System Model:'
        $(row).find('td:eq(3)').attr 'data-title', 'Serial:'
        $(row).find('td:eq(4)').attr 'data-title', 'Datacenter Zone:'
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
            '<div class="blue lighten-2 white-text z-depth-1 sync"><svg class="spinner" viewBox="0 0 50 50"><circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5"></circle></svg> Syncing</div>'
          else
            '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
        width: 200
        }
        { targets: 2
        orderable: false
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
        width: 325
        }
        { targets: 3
        orderable: false
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
