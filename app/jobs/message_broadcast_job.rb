class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast 'status_channel', job_id_update: message.id, status: message.status, updated_at: message.updated_at
  end
end
