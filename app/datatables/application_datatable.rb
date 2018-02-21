class ApplicationDatatable < AjaxDatatablesRails::Base
  include Rails.application.routes.url_helpers

  def initialize(view, options = {}, route = {})
    super(view, options)
    @route = route
    @extra_fields = []
    @blacklisted_fields = []
    @model_klass = @route[:model_name].singularize.camelize.constantize
    @model_relation = @model_klass.all
    initialize_category(@route[:category_name], @route[:category_id])
    after_initialize if respond_to? :after_initialize, true
  end

  # Give all tables the link_to helper
  def_delegator :@view, :link_to

  # XXX: Workaround from https://github.com/jbox-web/ajax-datatables-rails/issues/228
  def retrieve_records
    records = fetch_records
    records = filter_records(records)
    records = sort_records_including_ip_address(records) if datatable.orderable?
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
      elsif column
        queries << order.query(column.sort_query)
      end
    end
    records.order(sort_by.join(', '))
  end

  # def paginate_records(records)
  # end

  # ==== Insert 'presenter'-like methods below if necessary

  def get_raw_records
    params_filters = params[@route[:model_name].singularize.to_sym] || {}
    params_filters.each do |key, value|
      @model_relation = @model_relation.where(key.to_sym => value) if value.present?
    end
    @model_relation
  end

  def view_columns
    @view_columns ||= {}
    @model_klass.column_names.each do |column_name|
      orderable = true
      searchable = true
      searchable = false if @model_klass.columns_hash[column_name].type != :string
      @view_columns[column_name.to_sym] = {
        source: "#{@model_klass.name}.#{column_name}",
        searchable: searchable,
        orderable: orderable
      }
    end
    add_extra_view_columns(@view_columns) if respond_to? :add_extra_view_columns, true
    @view_columns
  end

  def data
    records.map do |record|
      r = {}
      record.class.column_names.each do |column_name|
        output = if respond_to? "filter_#{column_name}", true
                   send("filter_#{column_name}".to_sym, record.send(column_name.to_sym))
                 else
                   record.send(column_name.to_sym)
                 end

        if output.is_a?(Hash)
          r.merge!(output)
        else
          r[column_name] = output
        end
      end
      add_extra_fields(r, record)
      remove_blacklisted_fields(r)
      r
    end
  end

  def fields
    @model_klass.column_names + @extra_fields - @blacklisted_fields
  end

  protected

  def add_extra_fields(target, record)
    @extra_fields.each do |extra_field|
      send("add_#{extra_field}".to_sym, target, record) if respond_to? "add_#{extra_field}".to_sym, true
    end
  end

  def add_checkbox(target, record)
    target['checkbox'] = record.id
  end

  def add_url(target, record)
    options = []
    options << self.class.name.deconstantize.downcase.to_sym unless self.class.name.deconstantize.empty?
    options << record
    target['url'] = link_to('Details', options, class: 'btn blue lighten-2')
  end

  def remove_blacklisted_fields(target)
    @blacklisted_fields.each do |key|
      target.delete key
    end
  end

  def initialize_category(category_name, category_id)
    return false if category_name.blank?
    if respond_to? "initialize_#{category_name}", true
      send("initialize_#{category_name}".to_sym, category_id)
    elsif @model_klass.method_defined? category_name.to_sym
      @model_relation = @model_relation.where(category_name.to_sym => category_id)
    else
      raise ActionController::RoutingError, 'Bad Request'
    end
  end

  def filter_updated_at(input)
    input.iso8601
  end
end
