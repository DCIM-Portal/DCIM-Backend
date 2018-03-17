class Dcim::Search::ApplicationSearch
  def self.search(model, params, forbidden_fields = [])
    return self.new(model, params, forbidden_fields)
  end

  def self.parse_raw_filter(filter_name, term)
    if term.respond_to?(:each)
      return parse_hash_filter(filter_name, term)
    end
    [[filter_name, '=', term]]
  end

  def self.parse_hash_filter(filter_name, hash)
    output = []
    hash.each do |op, term|
      op = op.downcase.to_sym
      op_map = {
          eq: '=',
          ne: '<>',
          gt: '>',
          gte: '>=',
          lt: '<',
          lte: '<='
      }.freeze
      op = op_map[op]
      output << [filter_name, op, term]
    end
    output
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

    # Where, all match exactly
    and_filters.each do |field, op, term|
      collection = collection.where("#{field} #{op} ?", term)
    end

    # Magic search: Where, any case-insensitive match wildcard left and right
    @magic_search = @params.delete('magic_search') || {}
    if @magic_search['fields'].is_a?(String) && @magic_search['query'].is_a?(String)
      unsanitized_fields = @magic_search['fields'].split(',')
      sanitized_fields = searchable_fields & unsanitized_fields
      if sanitized_fields.sort != unsanitized_fields.sort
        raise ActionController::BadRequest.new(
            "Invalid or forbidden fields provided in magic_search[fields]: " \
            "#{unsanitized_fields - sanitized_fields}"
        )
      end
      statement = sanitized_fields.map { |field| "LOWER(#{field}) LIKE ?"}.join(" OR ")
      parameter = '%'+@magic_search['query'].downcase+'%'
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
        total_count: @results.total_entries,
        pages_count: @results.total_pages,
        first_page?: @results.current_page == 1,
        last_page?: @results.current_page == @results.total_pages,
        previous_page_number: @results.previous_page,
        next_page_number: @results.next_page,
        out_of_bounds?: @results.out_of_bounds?,
        offset: @results.offset
    }
  end

  def filters_info
    output = {}
    all = and_filters.map { |a, b, c| {key: a, operation: b, value: c} }
    output[:all] = all if all
    output
  end

  def searchable_fields
    @searchable_fields ||= @model.column_names - @forbidden_fields.map(&:to_s)
  end

  def and_filters
    return @and_filters if @and_filters
    filters = []
    @params.extract!(*searchable_fields).each do |key, value|
      filters += self.class.parse_raw_filter(key, value)
    end
    @and_filters = filters
  end

  def order_fields
    return @order_fields if @order_fields
    fields = []
    order = @params['order']
    if order.respond_to?(:each)
      order.each do |order_item|
        fields << order_field(order_item)
      end
      fields
    else
      order_field(order)
    end
  end

  def order_field(raw_order)
    field = raw_order[0].to_s
    if searchable_fields.include?(field)
      direction = raw_order[1].to_s
      if ['asc', 'desc'].include?(direction.downcase)
        return [field, direction.downcase]
      else
        raise ActionController::BadRequest.new(
            "Order for field \"#{field}\" must be \"asc\" or \"desc\" but this was provided: " +
                direction
        )
      end
    else
      raise ActionController::BadRequest.new(
          "Cannot order by this field: " +
              field
      )
    end
  end
end
