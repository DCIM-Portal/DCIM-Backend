App.status = App.cable.subscriptions.create "StatusChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    unless data.status.blank?
      message = '<p>The scan job ' + data.job_id_update + ' has been updated to ' + data.status + ' at ' + data.updated_at + '</p>'
      $('#action_cable_status').append(message)
      
      status_change = data.status
      job_id = '#' + data.job_id_update
      $(job_id).html(status_change)
