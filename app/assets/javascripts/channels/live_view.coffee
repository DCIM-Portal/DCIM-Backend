@subscribe_to_live_view = (name) ->
  return false unless name
  App.live_views ||= {}
  App.live_views[name] ||= App.cable.subscriptions.create {
    channel: "LiveViewChannel",
    name: name,
    },
    connected: ->
      connected_callback(name)
      # Called when the subscription is ready for use on the server
  
    disconnected: ->
      console.log("CONNECTION TO SERVER LOST")
      # Called when the subscription has been terminated by the server
  
    received: (data) ->
      received_callback(data)
      # Called when there's incoming data on the websocket for this channel
  
    watch_view: (parser, source, query) ->
      @perform 'watch_view', parser: parser, source: source, query: query
