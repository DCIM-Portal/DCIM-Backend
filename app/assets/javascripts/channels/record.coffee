@subscribe_to_record = (name) ->
  return false unless name
  App[name] ||= App.cable.subscriptions.create {
    channel: "RecordChannel",
    record: name
    },
    connected: ->
      # Called when the subscription is ready for use on the server
      connected_callback(name)
  
    disconnected: ->
      # Called when the subscription has been terminated by the server
  
    received: (data) ->
      sync_view(data)

    fullLoad: (id=null, associations=[]) ->
      @perform 'full_load', id: id, record: name, associations: associations
