jQuery ->
  $('#dtable').dataTable
    columnDefs: [ 
      orderable: false
      targets: [1,2,3,4,5,6,7]
    ]
    order: [ 0, 'desc' ]
    responsive: false
    scrollY: '365px'
