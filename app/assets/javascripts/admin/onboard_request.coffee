$(document).on 'turbolinks:load', ->

  document.render.detail_table.onboard_request = (view) ->
    #OnboardRequest main table
    document.detail_table_selector = '#onboard_requests_table'
    document.detail_table = $(document.detail_table_selector).dataTable
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].onboard_request = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.onboard_request.data)
        return undefined
      ajax: {
        url: $(document.detail_table_selector).data('source')
      }
      columns: [
        { "data": "id" },
        { "data": "status" },
        { "data": "updated_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><"middle"<"f_toolbar">><tr><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'Request ID:'
        $(row).find('td:eq(1)').attr 'data-title', 'Request Status:'
        $(row).find('td:eq(2)').attr 'data-title', 'Request Time:'
      order: [ 0, 'asc' ]

  document.render.category_table.onboard_request = (record) ->
    for key, value of record
      switch key
        when "status"
          value = text_to_request_status('onboard_request', value)
        when "updated_at"
          value = moment(value).format('MMMM DD YYYY, h:mma')
      $("#category_" + document.category_name + "_" + key).html(value)

  document.render.detail_table.onboard_request.bmc_host = (view) ->
    document.detail_table_selector = '#onboard_request_details_table'
    #OnboardRequest Host List Table
    document.detail_table = $(document.detail_table_selector).dataTable
      data: view
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
        {data: 'ip_address'}
        {data: 'brand'}
        {data: 'product'}
        {data: 'serial'}
        {data: 'power_status'}
        {data: 'sync_status'}
        {data: 'onboard_status'}
        {data: 'onboard_step'}
        {data: 'onboard_time'}
        {data: 'url'}
      ]
      order: [ 0, 'asc' ]
      dom: '<"top clearfix"lf><"middle"<"f_toolbar">><tr><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'BMC Address:'
        $(row).find('td:eq(1)').attr 'data-title', 'Brand:'
        $(row).find('td:eq(2)').attr 'data-title', 'Product:'
        $(row).find('td:eq(3)').attr 'data-title', 'Serial:'
        $(row).find('td:eq(4)').attr 'data-title', 'Power Status:'
        $(row).find('td:eq(5)').attr 'data-title', 'Sync Status:'
        $(row).find('td:eq(6)').attr 'data-title', 'Onboard Status:'
        $(row).find('td:eq(7)').attr 'data-title', 'Onboard Request Time:'
