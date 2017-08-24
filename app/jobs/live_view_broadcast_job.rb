class LiveViewBroadcastJob < ApplicationJob
  include MonitorMixin
  queue_as :liveview

  def perform(record, **kwargs)
    logger.debug "New broadcast request for #{record.to_json}"
    LiveViewSubscription.rerun
    logger.debug "Broadcast rerun requested"
    return false if LiveViewSubscription.locked?
    synchronize do
      LiveViewSubscription.lock(job_id)
      logger.debug "Broadcasts locked"
      while LiveViewSubscription.rerun?
        LiveViewSubscription.cancel_rerun
        logger.debug "Broadcast rerun canceled"
        subscriptions = LiveViewSubscription.all
        logger.debug "Processing all subscriptions..."
        # TODO: Improve performance by determining if source and query are likely to have been updated instead of blindly pushing to all subscribers.
        subscriptions.each do |id, params|
          output = "Unsupported push data"
          route = ::Rails.application.routes.recognize_path params['source']
          output = send("render_#{params['renderer']}", route, params) if respond_to? "render_#{params['renderer']}", :include_private
          ActionCable.server.broadcast("liveview_#{id}", {request: params, response: output})
        end
      end
      LiveViewSubscription.unlock
      logger.debug "Broadcasts unlocked"
    end
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

  def render_datatable(route, params)
    if !route[:klass].ancestors.include? ::AjaxDatatablesRails::Base
      output = "Invalid source in request: no matching route for #{params['source']}"
      logger.warn output
    else
      query = ::Rack::Utils.parse_nested_query(params['query']).deep_symbolize_keys
      liveview = LiveView.new(query.merge(route))
      output = ::ApplicationController.render json: route[:klass].new(liveview)
    end
    output
  end

  def render_model(route, params)
    # XXX
    rack_get(source: "#{params['source']}.#{params['query']}")
  end
end
