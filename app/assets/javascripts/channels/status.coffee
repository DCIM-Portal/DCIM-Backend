App.status = App.cable.subscriptions.create "StatusChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    unless data.status.blank?
      message = '<p>The scan job ' + data.job_id + ' has been updated to ' + data.status + ' at ' + data.updated_at + '</p>'
      new_row = '<tr><td>' + data.job_id + '</td>
                 <td>' + data.start_ip + '</td>
                 <td>' + data.end_ip + '</td>
                 <td>' + data.ilo_username + '</td>
                 <td>' + data.ilo_password + '</td>
                 <td id="' + data.job_id + '">' + data.status + '</td>
                 <td>' + data.created_at + '</td></tr>'
      status_change = data.status

      $('#action_cable_status').append(message)
      
      if(!$("#" + data.job_id).length)
        $('#action_cable_row').prepend(new_row)
        if($('#action_cable_row').is(":hidden"))
          $('#action_cable_row').show()

      status_id = '#' + data.job_id
      $(status_id).html(status_change)

