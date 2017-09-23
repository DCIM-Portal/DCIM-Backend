class Admin::BruteListDatatable < ApplicationDatatable
  def view_columns
    @view_columns ||= {
      id: { source: 'BruteList.id' },
      name: { source: 'BruteList.name' },
      created_at: { source: 'BruteList.created_at', searchable: false, orderable: true }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        name: record.name,
        created_at: record.updated_at.to_time.iso8601,
        url: link_to('Details', [:admin, record], class: 'btn blue lighten-2'),
        'DT_RowId' => record.id
      }
    end
  end

  private

  def get_raw_records
    BruteList.all
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
