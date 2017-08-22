class BmcScanRequestDatatable < ApplicationDatatable

  def_delegator :@view, :local_time
  def_delegator :@view, :link_to
  def_delegator :@view, :radio_button_tag

  def view_columns
    @view_columns ||= {
      id: {source: "BmcScanRequest.id"},
      name: {source: "BmcScanRequest.name"},
      start_address: {source: "BmcScanRequest.start_address"},
      end_address: {source: "BmcScanRequest.end_address"},
      status: {source: "BmcScanRequest.status", searchable: false, orderable: false},
      cred_list: {source: "BruteList.name"},
      zone: {source: "Zone.name"},
      updated_at: {source: "BmcScanRequest.updated_at", searchable: false, orderable: true}
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        name: record.name,
        start_address: record.start_address,
        end_address: record.end_address,
        status: record.status,
        cred_list: record.brute_list.name,
        zone: record.zone.name,
        updated_at: local_time(record.updated_at.to_time.iso8601, '%B %e %Y, %l:%M%P'),
        url: link_to('Details', record, class: "btn blue lighten-2"),
        'DT_RowId' => record.id
      }
    end
  end

  private

  def get_raw_records
    query = BmcScanRequest.includes(:brute_list, :zone).references(:brute_list, :zone).all
    params_bmc_scan_request = params[:bmc_scan_request] || {}
    params_bmc_scan_request.each do |key, value|
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
