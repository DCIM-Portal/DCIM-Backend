@subscribe_to_live_update = ->
  App.live_update ||= App.cable.subscriptions.create {
    channel: "LiveUpdateChannel",
    },
    connected: ->
      live_update_connected()
      # Called when the subscription is ready for use on the server
  
    disconnected: ->
      console.log("LiveUpdate disconnected!")
      # Called when the subscription has been terminated by the server
  
    received: (data) ->
      live_update_received(data)
      # Called when there's incoming data on the websocket for this channel
