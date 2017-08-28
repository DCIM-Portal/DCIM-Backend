class Admin::ZoneDatatable < ApplicationDatatable

  def_delegator :@view, :link_to

  def view_columns
    @view_columns ||= {
      dcim_id: {source: "Zone.id"},
      name: {source: "Zone.name"},
      foreman_id: {source: "Zone.foreman_location_id"},
      created_at: {source: "Zone.created_at", searchable: false, orderable: true}
    }
  end

  def data
    records.map do |record| {
      dcim_id: record.id,
      name: record.name,
      foreman_id: record.foreman_location_id,
      created_at: record.updated_at.to_time.iso8601,
      url: link_to('Details', [:admin, record], class: "btn blue lighten-2"),
      'DT_RowId' => record.id
    }
    end
  end

  private

  def get_raw_records
    Zone.all
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
