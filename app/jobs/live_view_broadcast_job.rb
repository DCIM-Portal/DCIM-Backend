class LiveViewBroadcastJob < ApplicationJob
  queue_as :default

  def perform(record, **kargs)
    subscriptions = LiveViewSubscription.all
    # TODO: Improve performance by determining if source and query are likely to have been updated instead of blindly pushing to all subscribers.
    subscriptions.each do |id, params|
      output = "Unsupported push data"
      if params['parser'] == "datatable"
        output = rack_get(source: params['source'], query: params['query'])
      elsif params['parser'] == "model"
        output = rack_get(source: "#{params['source']}.#{params['query']}")
      end
      ActionCable.server.broadcast("liveview_#{id}", {request: params, response: output})
    end
  end

  private

  # XXX: This method will make someone jump off a bridge.
  def rack_get(**kwargs)
    output = Rails.application.call({'rack.input'=>{}, 'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>kwargs[:source], 'QUERY_STRING'=>kwargs[:query]})[2].each do |body|
      body
    end
    output[0]
  end
end
