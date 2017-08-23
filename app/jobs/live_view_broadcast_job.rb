class LiveViewBroadcastJob < ApplicationJob
  queue_as :liveview

  def perform(record, **kwargs)
    logger.debug "New broadcast request for #{record.to_json}"
    LiveViewSubscription.rerun
    logger.debug "Broadcast rerun requested"
    return false if LiveViewSubscription.locked?
    LiveViewSubscription.lock(provider_job_id)
    logger.debug "Broadcasts locked"
    while LiveViewSubscription.rerun?
      LiveViewSubscription.cancel_rerun
      logger.debug "Broadcast rerun canceled"
      subscriptions = LiveViewSubscription.all
      logger.debug "Processing all subscriptions..."
      # TODO: Improve performance by determining if source and query are likely to have been updated instead of blindly pushing to all subscribers.
      subscriptions.each do |id, params|
        output = "Unsupported push data"
        if params['parser'] == "datatable"
          output = rack_get(source: params['source'], query: params['query'])
        elsif params['parser'] == "model"
          output = rack_get(source: "#{params['source']}.#{params['query']}")
        end
        ActionCable.server.broadcast("liveview_#{id}", {request: params, response: output})
#        logger.debug "liveview_#{id}"
#        logger.debug({request: params, response: output})
      end
    end
    LiveViewSubscription.unlock
    logger.debug "Broadcasts unlocked"
  end

  private

  def logger
    Sidekiq::Logging.logger || Rails.logger
  end

  # XXX: This method will make someone jump off a bridge.
  def rack_get(**kwargs)
    output = Rails.application.call({'rack.input'=>{}, 'REQUEST_METHOD'=>'GET', 'PATH_INFO'=>kwargs[:source], 'QUERY_STRING'=>kwargs[:query]})[2].each do |body|
      body
    end
    output[0]
  end
end
