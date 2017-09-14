$(document).on 'turbolinks:load', ->

  document.render.detail_table.bmc_host = (view) ->
    document.detail_table_selector = '#bmc_hosts_table'
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
        {data: 'zone_name'}
        {data: 'power_status'}
        {data: 'sync_status'}
        {data: 'onboard_status'}
        {data: 'onboard_step'}
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
        $(row).find('td:eq(5)').attr 'data-title', 'Datacenter Zone:'
        $(row).find('td:eq(6)').attr 'data-title', 'Power Status:'
        $(row).find('td:eq(7)').attr 'data-title', 'Last Sync Status:'
        $(row).find('td:eq(8)').attr 'data-title', 'Onboard Status:'
        $(row).find('td:eq(9)').attr 'data-title', 'Synchronize Date:'
