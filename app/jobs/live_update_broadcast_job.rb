class LiveUpdateBroadcastJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActionCable.server.broadcast('liveupdate', Time.now.to_i)
  end
end
