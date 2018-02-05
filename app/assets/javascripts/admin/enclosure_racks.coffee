$(document).on 'turbolinks:load', ->

  document.render.detail_table.enclosure_rack = (view) ->
    # Enclosure Rack main table
    document.detail_table_selector = '#rack_table'
    document.detail_table = $(document.detail_table_selector).dataTable
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].brute_list = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.brute_list.data)
        return undefined
      ajax: {
        url: $(document.detail_table_selector).data('source')
      }
      columns: [
        { "data": "id" },
        { "data": "name" },
        { "data": "zone_name"},
        { "data": "created_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><t><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'Enclosure Rack ID:'
        $(row).find('td:eq(1)').attr 'data-title', 'Enclosure Rack Name:'
        $(row).find('td:eq(2)').attr 'data-title', 'Datacenter Zone Name:'
        $(row).find('td:eq(3)').attr 'data-title', 'Date Created:'
      order: [ 0, 'asc' ]

  # Enclosure Rack Form Dynamic Text Logic

  $('form.new_enclosure_rack').on 'keyup mouseup', '.dynamic-text', ->
    console.log "IT WORKS"
    start_at = $('#enclosure_rack_start_at').val()
    quantity = $('#enclosure_rack_quantity').val()
    zero_pad_digits = $('#enclosure_rack_zero_pad_to').val()
    rack_name = $('#enclosure_rack_name').val()
    end_number = countLast(start_at, quantity)
    if rack_name != '' and Number(start_at) >= 1 and Number(quantity) == 1
      $('#last_rack_number').empty()
      $('#last_rack_name').empty()
      $('span.many_racks').hide()
      $('#first_rack_name').html rack_name
      $('#first_rack_number').html pad(start_at, zero_pad_digits)
      $('div.dynamic-text').show()
    else if rack_name != '' and Number(start_at) >= 1 and Number(quantity) > 1
      $('#first_rack_name').html rack_name
      $('#first_rack_number').html pad(start_at, zero_pad_digits)
      $('#last_rack_number').html pad(end_number, zero_pad_digits)
      $('#last_rack_name').html rack_name
      $('span.many_racks').show()
      $('div.dynamic-text').show()
    else
      $('span.many_racks').hide()
      $('div.dynamic-text').hide()
      $('#first_rack_number').empty()
      $('#first_rack_name').empty()
      $('#last_rack_name').empty()
      $('#last_rack_number').empty()
  
  countLast = (start_at, quantity) ->
    start_at = start_at - 1
    number_count = +quantity + +start_at
    number_count.toString()
  
  pad = (str, max) ->
    str = str.toString()
    return if str.length < max then pad("0" + str, max) else str
