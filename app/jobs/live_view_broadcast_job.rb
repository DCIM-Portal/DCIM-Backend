class LiveViewBroadcastJob < ApplicationJob
  queue_as :default

  def perform(record, **kargs)
    subscriptions = LiveViewSubscription.all
    subscriptions.each do |uuid, params|
      output = "Unsupported push data"
      if params['parser'] == "datatable"
        # XXX: The following will make someone jump off a bridge.
        output = Rails.application.call({'rack.input'=>{}, 'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>params['source'], 'QUERY_STRING'=>params['query']})[2].each do |body|
          body
        end
        output = output[0]
      end
      ActionCable.server.broadcast("liveview_#{uuid}", {request: params, response: output})
    end
  end
end
