class LiveViewChannel < ApplicationCable::Channel
  def subscribed
    stream_from "liveview_#{id}"
    LiveViewSubscription.create(id)
  end

  def unsubscribed
    LiveViewSubscription.destroy(id)
  end

  def watch_view(data)
    redisfied_data = {
      'name': params[:name].to_s,
      'renderer': data["renderer"].to_s,
      'source': data["source"].to_s,
      'query': data["query"].to_s
    }
    LiveViewSubscription.set(id, *redisfied_data)
  end

  private

  def id
    "#{uuid}_#{params[:name]}"
  end
end
