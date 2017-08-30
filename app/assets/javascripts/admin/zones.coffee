#Zones coffee scripts
$(document).on 'turbolinks:load', ->

  $('#async_wrapper').show()

  document.render.detail_table.zone = (view) ->
    #Zone Main Table
    document.detail_table_selector = '#zone_table'
    document.detail_table = $(document.detail_table_selector).dataTable
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].zone = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.zone.data)
        return undefined
      ajax: {
        url: $(document.detail_table_selector).data('source')
        data: (d) ->
          if $('#filters').length
            return $.extend {}, $('#filters').serializeObject(), d
          else if document.datatables_state_cache[document.href]?.zone?.filters?
            return $.extend {}, $(document.datatables_state_cache[document.href]?.zone?.filters).serializeObject(), d
          return d
      }
      columns: [
        { "data": "dcim_id" },
        { "data": "name" },
        { "data": "foreman_id" },
        { "data": "created_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><t><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'DCIM Zone ID:'
        $(row).find('td:eq(1)').attr 'data-title', 'Zone Name:'
        $(row).find('td:eq(2)').attr 'data-title', 'Foreman Zone ID:'
        $(row).find('td:eq(3)').attr 'data-title', 'Date Added:'
      order: [ 0, 'asc' ]

  document.render.category_table.zone = (record) ->
    for key, value of record
      $("#category_" + document.category_name + "_" + key).html(value)
      $(".category_" + document.category_name + "_" + key).html(value)
      $("#category_" + document.category_name + "_updated_at").html(moment(value).format('MMM DD YYYY, h:mma')) if key == "updated_at"

  document.render.detail_table.zone.bmc_host = (view) ->
    #Zone Host List Table
    document.detail_table_selector = '#zone_details_table'
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
