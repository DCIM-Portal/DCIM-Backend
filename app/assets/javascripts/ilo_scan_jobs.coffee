$(document).on 'turbolinks:load', ->

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
      $('#dtable').show()

  $('#detail_table').DataTable
    deferRender: true
    columnDefs: [ {
      orderable: false
      searchable: false
      className: 'checkbox'
      checkboxes: selectRow: true
      targets: 0
    } ]
    select: style: 'multi'
    order: [
      1
      'asc'
    ]
    scrollY: '365px'
    drawCallback: ->
      $('#detail_table').show()


$(document).on 'turbolinks:before-cache', ->
  $('#dtable').DataTable().destroy()
  $('#dtable').hide()
  $('#detail_table').DataTable().destroy()
  $('#detail_table').hide()
