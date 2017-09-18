class ApplicationDatatable < AjaxDatatablesRails::Base
  include Rails.application.routes.url_helpers

  # Give all tables the link_to helper
  def_delegator :@view, :link_to

  # XXX: Workaround from https://github.com/jbox-web/ajax-datatables-rails/issues/228
  def retrieve_records
    records = fetch_records
    records = filter_records(records)
    records = sort_records_including_ip_address(records)     if datatable.orderable?
    records = paginate_records(records) if datatable.paginate?
    records
  end

  # ==== These methods represent the basic operations to perform on records
  # and feel free to override them

  # def filter_records
  # end

  # def sort_records(records)
  # end
  def sort_records_including_ip_address(records)
    sort_by = datatable.orders.inject([]) do |queries, order|
      column = order.column
      if column && column.field == :ip_address
        # XXX: Only works for MySQL?
        queries << order.query("INET_ATON(#{column.sort_query})")
      else
        queries << order.query(column.sort_query) if column
      end
    end
    records.order(sort_by.join(", "))
  end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary

end
