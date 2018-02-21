class Admin::BmcHostBaseDatatable < ApplicationDatatable
  def after_initialize
    @extra_fields += %w[url checkbox zone_name host_path]
    @blacklisted_fields += %w[username password]
  end

  # def view_columns
  #  @view_columns ||= {
  #    ip_address: { source: 'BmcHost.ip_address' },
  #    brand: { source: 'BmcHost.brand' },
  #    product: { source: 'BmcHost.product' },
  #    serial: { source: 'BmcHost.serial' },
  #    zone_name: { source: 'Zone.name' },
  #    power_status: { source: 'BmcHost.power_status', searchable: false, orderable: true },
  #    sync_status: { source: 'BmcHost.sync_status', searchable: false, orderable: true },
  #    onboard_status: { source: 'BmcHost.onboard_status', searchable: false, orderable: true },
  #    onboard_step: { source: 'BmcHost.onboard_step', searchable: false, orderable: false },
  #    onboard_time: { source: 'BmcHost.onboard_updated_at', searchable: false, orderable: true },
  #    updated_at: { source: 'BmcHost.updated_at', searchable: false, orderable: true }
  #  }
  # end

  # def data
  #  records.map do |record|
  #    {
  #      ip_address: record.ip_address,
  #      brand: record.brand,
  #      product: record.product,
  #      serial: record.serial,
  #      zone_name: record.zone.name,
  #      power_status: record.power_status,
  #      sync_status: record.sync_status,
  #      onboard_status: record.onboard_status,
  #      onboard_step: record.onboard_step,
  #      onboard_time: record.onboard_updated_at.try(:iso8601),
  #      updated_at: record.updated_at.iso8601,
  #      checkbox: record.id,
  #      zone_id: record.zone.id,
  #      url: link_to('Details', [:admin, record], class: 'btn blue lighten-2'),
  #      'DT_RowId' => record.id,
  #      host_path: admin_bmc_host_path(record.id)
  #    }
  #  end
  # end

  def add_extra_view_columns(view_columns)
    view_columns[:zone_name] = { source: 'Zone.name' }
  end

  def add_zone_name(target, record)
    target['zone_name'] = record.zone.name
  end

  def add_host_path(target, record)
    target['host_path'] = admin_bmc_host_path(record.id)
  end
end
