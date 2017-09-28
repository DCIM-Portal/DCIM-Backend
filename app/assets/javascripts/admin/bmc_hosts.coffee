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
        $(row).find('td:eq(9)').attr 'data-title', 'Synchronize Time:'
        $(row).attr 'data-source', data.host_path

  document.render.category_table.bmc_host = (record) ->
    for key, value of record
      switch key
        when "status"
          value = text_to_request_status('bmc_host', value)
        when "updated_at", "onboard_updated_at"
          value = moment(value).format('MMMM DD YYYY, h:mma')
        when "onboard_status"
          value = text_to_onboard_status(value + ': ' + record["onboard_step"])
        when "system"
          document.render.category_table.system?(value)
        # TODO: Badge for power status
      $("#category_" + document.category_name + "_" + key).html(value) if value != $("#category_" + document.category_name + "_" + key).html()
      $(".category_" + document.category_name + "_" + key).html(value) if value != $(".category_" + document.category_name + "_" + key).html()
