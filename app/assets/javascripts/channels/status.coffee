App.status = App.cable.subscriptions.create "StatusChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel

    #Define Prettier Dates with Momentjs
    create_date = moment(data.created_at).format('MMM D YYYY, h:mm A')
    update_date = moment(data.updated_at).format('MMM D YYYY, h:mm:ss A')

    #Send Alert Upon Channel Broadcast
    $.notify({
      title: '<span class="glyphicon glyphicon-list-alt"></span><strong> Scan Job ' + data.job_id + '</strong>',
      message: '<mark><em>' + data.status + '</em></mark> at ' + update_date + ''
    },{
      element: 'body',
      newest_on_top: false,
      placement: {
        from: "bottom",
        align: "right"
      },
      offset: 20,
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

    #If Job is anything but deleted
    if data.status != "Job Deleted"

      #Variable for new table row
      new_row = '<tr id="row' + data.job_id + '"><td>' + data.job_id + '</td>
                 <td>' + data.start_ip + '</td>
                 <td>' + data.end_ip + '</td>
                 <td>' + data.ilo_username + '</td>
                 <td>' + data.ilo_password + '</td>
                 <td id="' + data.job_id + '">' + data.status + '</td>
                 <td>' + create_date + '</td></tr>'

      #Variable for new status
      status_change = data.status

      #If Job ID Does Not Exist, create new row
      if(!$("#" + data.job_id).length)
        $('#action_cable_row').prepend(new_row)
        if($('#action_cable_row').is(":hidden"))
          $('#action_cable_row').show()

      #Change Status of Job
      status_id = '#' + data.job_id
      $(status_id).html(status_change)
    else
      #Hide row if job is deleted
      $("#row" + data.job_id).hide()

