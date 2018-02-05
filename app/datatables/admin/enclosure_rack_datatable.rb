class Admin::EnclosureRackDatatable < ApplicationDatatable
  def view_columns
    @view_columns ||= {
      id: { source: 'EnclosureRack.id' },
      name: { source: 'EnclosureRack.name' },
      zone_name: { source: 'EnclosureRack.zone.name' },
      created_at: { source: 'EnclosureRack.created_at', searchable: false, orderable: true }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        name: record.name,
        zone_name: record.zone.name,
        created_at: record.updated_at.to_time.iso8601,
        url: link_to('Details', [:admin, record], class: 'btn blue lighten-2'),
        'DT_RowId' => record.id
      }
    end
  end

  private

  def get_raw_records
    EnclosureRack.includes(:zone).references(:zone).all
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
