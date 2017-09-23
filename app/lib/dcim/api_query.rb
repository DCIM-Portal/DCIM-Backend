module Dcim
  class ApiQuery
    def initialize(**kwargs)
      @resource = kwargs[:resource]
      append_chain(kwargs[:method], kwargs[:args])
    end

    def append_chain(method, args)
      (@query ||= []) << method.to_s
      @query += args
    end

    def method_missing(method, *args)
      if %i[get post delete put].include?(method)
        return request.send(method, args)
      end
      append_chain(method, args)
      self
    end

    %i[get post delete put].each do |method|
      define_method(method) do |payload = nil, **kwargs|
        options = @resource.instance_variable_get(:@options)
        url     = @resource.instance_variable_get(:@url)
        payload = kwargs[:payload] if payload.nil?

        # With JSON payload, add header "Content-Type: application/json"
        if payload.is_a? String
          suppress(JSON::ParserError) do
            JSON.parse(payload)
            kwargs[:headers] ||= {}
            kwargs[:headers].merge!('Content-Type' => 'application/json')
          end
        end

        options.merge!(kwargs)

        result = RestClient::Request.execute(
          options.merge(
            method: method,
            url: @resource.send(:concat_urls, url, @query.join('/')),
            payload: payload
          )
        )
        ::Dcim::ApiResult.new(result)
      end
    end
  end
end
