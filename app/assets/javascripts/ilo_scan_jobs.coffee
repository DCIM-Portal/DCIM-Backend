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
      }
    ]
    scrollY: '365px'
    responsive: true
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
