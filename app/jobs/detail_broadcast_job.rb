class DetailBroadcastJob < ApplicationJob
  queue_as :default

  def perform(detail)
    ActionCable.server.broadcast 'status_channel', address: detail.ilo_address, model: detail.server_model, serial:  detail.server_serial, detail_id: detail.ilo_scan_job_id, power_status: detail.power_status, provision_status: detail.provision_status
  end
end
