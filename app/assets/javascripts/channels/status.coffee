App.status = App.cable.subscriptions.create "StatusChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel

    #Define Prettier Dates with Momentjs
    create_date = moment(data.created_at).format('MMM DD YYYY, h:mm A')
    update_date = moment(data.updated_at).format('MMM D YYYY, h:mm:ss A')

    #Send Alert Upon Channel Broadcast
    $.notify({
      title: '<span class="glyphicon glyphicon-list-alt"></span><strong> Scan Job ' + data.job_id + '</strong>',
      message: '<span class="text-warning"><em>' + data.status + '</em></span> at ' + update_date + ''
    },{
      element: 'body',
      newest_on_top: false,
      placement: {
        from: "bottom",
        align: "right"
      },
      offset: 20,
      type: 'info',
      spacing: 5,
      delay: 10000,
      animate: {
        enter: 'animated fadeInUp',
        exit: 'animated fadeOutDown'
      }, template: '<div data-notify="container" class="col-xs-11 col-sm-2 alert alert-{0}" role="alert">' +
        '<button type="button" aria-hidden="true" class="close" data-notify="dismiss">×</button>' +
        '<span data-notify="icon"></span> ' +
        '<span data-notify="title">{1}</span> ' +
        '<span data-notify="message">{2}</span>' +
        '<div class="progress" data-notify="progressbar">' +
        '<div class="progress-bar progress-bar-{0}" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>' +
        '</div>' +
        '<a href="{3}" target="{4}" data-notify="url"></a>' +
        '</div>'
    });

    table = $('#dtable').DataTable()
    #If Job is anything but deleted
    if data.status == "Created"

      count = 0
      new_data = [
        data.job_id
        data.start_ip
        data.end_ip
        data.ilo_username
        data.ilo_password
        data.status
        create_date
        '<a class="btn btn-small btn-info" href="/ilo_scan_jobs/' + data.job_id + '">Details</a>'
      ]
      new_row = table.row.add(new_data).draw().nodes().to$().find('td').each ->
        $(this).attr 'id', 'td_' + count++ + '_' + data.job_id

      new_row
      id = $('#row' + data.job_id).val()
      table.row(new_row).node().id = 'row' + data.job_id

    else if data.status != "Created" && data.status != "Job Deleted"
      table.cell('#td_5_' + data.job_id).data(data.status)
      
    else
      tr = "#row" + data.job_id
      table.row(tr).remove().draw()
      
