jQuery ->
  $('#dtable').dataTable
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
