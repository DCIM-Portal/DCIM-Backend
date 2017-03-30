window.progress_bars = {}

$(document).on 'turbolinks:load', ->

  $('.prov').prop 'disabled', true
  $('#confirm').keyup ->
    $('.prov').prop 'disabled', if @value != 'Provision Servers' then true else false

  $('#dtable').DataTable
    deferRender: true
    columnDefs: [ 
      orderable: false
      targets: [1,2,3,4,5,6,7]
      { width: 50
      targets: 0 }
      { width: 150
      targets: [1,2,3,4] }
      { width: 320
      targets: 5 }
      { width: 220
      targets: 6 }
    ]
    order: [ 0, 'desc' ]
    responsive: true
    scrollY: '365px'
    drawCallback: ->
      $('#main_header').show()
      $('#main_table_body').show()
      $('.overlay').hide()

  detail_table = $('#detail_table').DataTable
    deferRender: true
    order: [
      0
      'asc'
    ]
    dom: 'lfBtip'
    select: 'os'
    buttons: [
      {
        text: '<i class="fa fa-check-square"><span class="button_text">Select All</span></i>'
        action: ->
          detail_table.rows( { search: 'applied' } ).select()
        className: 'select_all_button'
      }
      {
        text: '<i class="fa fa-window-close"><span class="button_text">Select None</span></i>'
        action: ->
          detail_table.rows().deselect()
        className: 'select_none_button'
      }
      {
        extend: 'copyHtml5'
        text:  '<i class="fa fa-files-o"><span class="button_text">Copy to Clipboard</span></i>'
        exportOptions: {
          rows: '.selected'
        }
        className: 'copy_button'
      }
      {
        extend: 'csvHtml5'
        text: '<i class="fa fa-file-text"><span class="button_text">Save to Excel</span></i>'
        exportOptions: {
          rows: '.selected'
        }
        className: 'csv_button'
      }
    ]
    columnDefs: [
      { targets: 3
      data: 3
      render: (data, type, full, meta) ->
        if data == 'On'
          '<div class="power_on"><i class="fa fa-power-off"></i> ' + data + '</div>'
        else if data == 'Off'
          '<div class="power_off"><i class="fa fa-power-off"></i> ' + data + '</div>'
        else
          data
      },
      { targets: 4
      data: 4
      render: (data, type, full, meta) ->
        if !(/((Initial Scan)|(Error)|(Completed: Discover))/.test(data))
          '<div class="prov_message">' + data + ' <div class="throbber-loader"></div></div>'
        else if data == "Task Completed: Discover"
          '<div class="progress_finish"><i class="fa fa-check-circle-o" aria-hidden="true"></i> Server Discovered into Backend</div>'
        else if (/(Error))/.test(data))
          '<div class="progress_error"><i class="fa fa-times" aria-hidden="true"></i> ' + data + '</div>'
        else
          data
      }
    ]
    scrollY: '365px'
    responsive: true
    createdRow: (row, data, dataIndex) ->
      address = $(row).find('td:eq(0)').html()
      progress_status = $(row).find('td:eq(4)').html()
      escapeSelector = (s) ->
        s.replace /\./g, "\\."
      window.progress_bars[address] = $($.parseHTML('<div class="progress"><div class="progress-bar progress-bar-striped active" role="progressbar" style="width:100%">Waiting for progress&hellip;</div></div>'))
      $(row).find('td:eq(4)').prepend window.progress_bars[address]
      $(row).find('td:eq(4)').attr 'id', "provision_#{ address }"
      $(row).find('td:eq(3)').attr 'id', "power_#{ address }"
      if !(/((Initial Scan)|(Error)|(Server Discovered into Backend))/.test(progress_status))
        $("td#" + escapeSelector("provision_#{ address }") + " div.progress").show()

    drawCallback: ->
      $('#main_header').show()
      $('#main_table_body').show()
      $('.black-btn').show()
      $('.overlay').hide()

$(document).on 'turbolinks:before-cache', ->
  $('.overlay').show()
  $('#main_table_body').hide()
  $('#main_header').hide()
  $('.black-btn').hide()
  $('#dtable').DataTable().destroy()
  $('#detail_table').DataTable().destroy()
  $('tr').removeClass('selected')
  $('.prov').prop 'disabled', true
  $('#confirm').keyup ->
    $('.prov').prop 'disabled', if @value != 'Provision Servers' then true else false


$(document).ready ->
  $('.prov').prop 'disabled', true
  $('#confirm').keyup ->
    $('.prov').prop 'disabled', if @value != 'Provision Servers' then true else false

  provision_cell_observer = new MutationObserver((mutations) ->
    mutations.forEach (mutation) ->
      if mutation.addedNodes.length
        for node in mutation.addedNodes
          cell = $(node).find('td[id^=provision_]')
          if !cell.length
            continue
          address = cell.attr('id').split('_')[1]
          cell.prepend window.progress_bars[address]
  )
  provision_cell_observer_configuration = { childList: true, subtree: true }
  provision_cell_observer.observe($('#detail_table').get(0), provision_cell_observer_configuration)
