class LiveUpdateChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'liveupdate'
  end

  def unsubscribed; end
end
