class Dcim::Search::ApplicationSearch
  def self.search(model, params, forbidden_fields = [])
    new(model, params, forbidden_fields)
  end

  attr_reader :results

  def initialize(model, params, forbidden_fields)
    @model = model
    @params = params
    @forbidden_fields = forbidden_fields
    search
  end

  def search
    collection = @model.all

    # Filters
    filters_info.each do |filter_group|
      first = true
      filter_group.each do |filter|
        field = filter[:key]
        op = filter[:operation]
        term = filter[:value]
        # (op == '=') is used to match enums
        if op == '=' && first
          collection = collection.where(field => term)
          first = false
        elsif op == '='
          collection = collection.or(@model.where(field => term))
        elsif first
          collection = collection.where("#{field} #{op} ?", term)
          first = false
        else
          collection = collection.or(@model.where("#{field} #{op} ?", term))
        end
      end
    end

    # Magic search: Where, any case-insensitive match wildcard left and right
    @search = @params.delete('search') || {}
    if @search['fields'].is_a?(String) && @search['query'].is_a?(String)
      unsanitized_fields = @search['fields'].split(',')
      sanitized_fields = searchable_fields & unsanitized_fields
      if sanitized_fields.sort != unsanitized_fields.sort
        raise ActionController::BadRequest, 'Invalid or forbidden fields provided in search[fields]: ' \
          "#{unsanitized_fields - sanitized_fields}"
      end
      statement = sanitized_fields.map { |field| "LOWER(#{field}) LIKE ?" }.join(' OR ')
      parameter = '%' + @search['query'].downcase + '%'
      parameters = Array.new(sanitized_fields.count, parameter)
      collection = collection.where(statement, *parameters)
    end

    # Sort
    order_fields.each do |field, direction|
      collection = collection.order(field => direction)
    end

    # Pagination
    page = @params.delete('page') || 1
    per_page = @params.delete('per_page') || 10
    collection = collection.paginate(page: page, per_page: per_page)

    @results = collection
  end

  def pagination_info
    return nil unless @results
    {
      records_count: @results.total_entries,
      pages_count: @results.total_pages,
      records_per_page: @results.per_page,
      first_page?: @results.current_page == 1,
      last_page?: @results.current_page == @results.total_pages,
      previous_page_number: @results.previous_page,
      current_page_number: @results.current_page,
      next_page_number: @results.next_page,
      out_of_bounds?: @results.out_of_bounds?,
      offset: @results.offset
    }
  end

  def search_info
    return {} unless @search['fields'].is_a?(String) && @search['query'].is_a?(String)
    {
      fields: @search['fields'].split(','),
      query: @search['query']
    }
  end

  def filters_info
    return @filters if @filters
    @filters = []
    raw_filters = @params.delete('filters')
    return @filters unless raw_filters.respond_to?(:keys)
    raw_filters.each do |filter_group_name, raw_filter_group|
      filter_group = []
      raw_filter_group.each do |raw_filter|
        key, operation, value = validated_filter(raw_filter, "\"#{filter_group_name}\"")
        filter_group << {
          key: key,
          operation: operation,
          value: value
        }
      end
      @filters << filter_group
    end
    @filters
  end

  def validated_filter(raw_filter, filter_group_name = 'of unknown name')
    permitted_operations = %w[= <> > >= < <=]
    match = raw_filter.match(/([^<=>]+)([<=>]+)(.*)/)
    raise ActionController::BadRequest, "Filter group #{filter_group_name} contains an invalid filter item" unless match.is_a?(MatchData)
    key, operation, value = match.captures
    raise ActionController::BadRequest, "Invalid or forbidden field name \"#{key}\" in filter group #{filter_group_name}" unless searchable_fields.include?(key)
    unless permitted_operations.include?(operation)
      raise ActionController::BadRequest, "Invalid operation \"#{operation}\" for field name \"#{key}\" in filter group #{filter_group_name}"
    end
    raise ActionController::BadRequest, "Value required but not provided for field name \"#{key}\" in filter group #{filter_group_name}" if value.empty?
    [key, operation, value]
  end

  def order_info
    order_fields.map { |a, b| { field: a, direction: b } } if order_fields
  end

  def searchable_fields
    @searchable_fields ||= @model.column_names - @forbidden_fields.map(&:to_s)
  end

  def order_fields
    return @order_fields if @order_fields
    fields = []
    order = @params['order']
    return [] unless order
    raise ActionController::BadRequest, 'Order parameter must be iterable' unless order.respond_to?(:each)
    order.each do |order_item|
      fields << order_field(order_item)
    end
    @order_fields = fields
  end

  def order_field(raw_order)
    field = raw_order[0].to_s
    unless searchable_fields.include?(field)
      raise ActionController::BadRequest, 'Cannot order by this field: ' +
                                          field
    end

    direction = raw_order[1].to_s
    unless %w[asc desc].include?(direction.downcase)
      raise ActionController::BadRequest, "Order for field \"#{field}\" must be \"asc\" or \"desc\" but this was provided: " +
                                          direction
    end

    [field, direction.downcase]
  end
end
