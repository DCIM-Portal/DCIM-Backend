class Admin::BmcScanRequestDetailsDatatable < Admin::BmcHostBaseDatatable
  private

  def get_raw_records
    query = BmcScanRequest.find(params[:id]).bmc_hosts.includes(:zone).references(:zone)
    params_bmc_host = params[:bmc_host] || {}
    params_bmc_host.each do |key, value|
      query = query.where(key.to_sym => value) if value.present?
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
