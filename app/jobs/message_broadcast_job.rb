class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast 'status_channel', job_id: message.id, start_ip: message.start_ip, end_ip: message.end_ip, ilo_username: message.ilo_username, ilo_password: message.ilo_password, status: message.status, created_at: message.created_at, updated_at: message.updated_at, server_count: message.count
  end
end
