class LiveViewChannel < ApplicationCable::Channel
  def subscribed
    stream_from "liveview_#{uuid}"
    LiveViewSubscription.create(uuid)
  end

  def unsubscribed
    LiveViewSubscription.destroy(uuid)
  end

  def watch_view(data)
    redisfied_data = {
      'id': data["id"].to_s,
      'parser': data["parser"].to_s,
      'source': data["source"].to_s,
      'query': data["query"].to_s
    }
    LiveViewSubscription.set(uuid, *redisfied_data)
  end
end
