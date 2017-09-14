class Admin::ZoneDetailsDatatable < ApplicationDatatable

  def_delegator :@view, :link_to

  def view_columns
    @view_columns ||= {
      ip_address: {source: "BmcHost.ip_address"},
      brand: {source: "BmcHost.brand"},
      product: {source: "BmcHost.product"},
      serial: {source: "BmcHost.serial"},
      power_status: {source: "BmcHost.power_status", searchable: false, orderable: true},
      sync_status: {source: "BmcHost.sync_status", searchable: false, orderable: true},
      onboard_status: {source: "BmcHost.onboard_status", searchable: false, orderable: true},
      onboard_step: {source: "BmcHost.onboard_step", searchable: false, orderable: false},
      updated_at: {source: "BmcHost.updated_at", searchable: false, orderable: true}
    }
  end

  def data
    records.map do |record| {
      ip_address: record.ip_address,
      brand: record.brand,
      product: record.product,
      serial: record.serial,
      power_status: record.power_status,
      sync_status: record.sync_status,
      onboard_status: record.onboard_status,
      onboard_step: record.onboard_step,
      updated_at: record.updated_at.to_time.iso8601,
      checkbox: record.id,
      url: link_to('Details', [:admin, record], class: "btn blue lighten-2"),
      'DT_RowId' => record.id
    }
    end
  end

  private

  def get_raw_records
    query = Zone.find(params[:id]).bmc_hosts
    params_bmc_host = params[:bmc_host] || {}
    params_bmc_host.each do |key, value|
      query = query.where({key.to_sym => value}) if value.present?
    end
    query
  end


  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records(records)
  # end

  # def sort_records(records)
  # end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary
end
