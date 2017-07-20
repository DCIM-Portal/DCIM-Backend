module Dcim

  class ApiQuery

    def initialize(**kwargs)
      @resource = kwargs[:resource]
      self.append_chain(kwargs[:method], kwargs[:args])
    end

    def append_chain(method, args)
      (@query ||= []) << method.to_s
      @query += args
    end

    def method_missing(method, *args)
      if [:get, :post, :delete, :put].include?(method)
        return request.send(method, args)
      end
      self.append_chain(method, args)
      self
    end

    [:get, :post, :delete, :put].each do |method|
      define_method(method) do |*payload, **kwargs|
        options = @resource.instance_variable_get(:@options)

        # With JSON payload, add header "Content-Type: application/json"
        if payload[0].is_a? String
          begin
            JSON.parse(payload[0])
            kwargs[:headers] ||= {}
            kwargs[:headers].merge!({'Content-Type':'application/json'})
          rescue JSON::ParserError => e
          end
        end

        options.merge!(kwargs)

        resource = RestClient::Resource.new(@resource.instance_variable_get(:@url),
                                            **options)
        rest_query = resource[@query.join('/')]
        result = rest_query.send(method, *payload)
        ApiResult.new(result)
      end
    end

  end

end
