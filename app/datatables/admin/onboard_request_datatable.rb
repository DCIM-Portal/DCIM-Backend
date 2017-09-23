class Admin::OnboardRequestDatatable < ApplicationDatatable
  def view_columns
    @view_columns ||= {
      id: { source: 'OnboardRequest.id' },
      status: { source: 'OnboardRequest.status', searchable: false, orderable: true },
      updated_at: { source: 'OnboardRequest.updated_at', searchable: false, orderable: true }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        status: record.status,
        updated_at: record.updated_at.to_time.iso8601,
        url: link_to('Details', [:admin, record], class: 'btn blue lighten-2'),
        'DT_RowId' => record.id
      }
    end
  end

  private

  def get_raw_records
    query = OnboardRequest.all
    params_onboard_request = params[:onboard_request] || {}
    params_onboard_request.each do |key, value|
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
