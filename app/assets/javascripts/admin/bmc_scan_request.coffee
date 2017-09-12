$(document).on 'turbolinks:load', ->

  document.render.detail_table.bmc_scan_request = (view) ->
    #BmcScanRequest main table
    document.detail_table_selector = '#bmc_scan_requests_table'
    document.detail_table = $(document.detail_table_selector).dataTable
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].bmc_scan_request = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.bmc_scan_request.data)
        return undefined
      ajax: {
        url: $(document.detail_table_selector).data('source')
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
      order: [ 0, 'asc' ]
  
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
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].bmc_host = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.bmc_host.data)
        return undefined
      ajax: {
        url: $(document.detail_table_selector).data('source')
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
