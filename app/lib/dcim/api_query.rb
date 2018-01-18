module Dcim
  class ApiQuery
    include Dcim::Logger

    def initialize(**kwargs)
      @resource = kwargs[:resource]
      @retries = kwargs[:retries] || 0
      append_chain(kwargs[:method], kwargs[:args])
    end

    def append_chain(method, args)
      (@query ||= []) << method.to_s
      @query += args
    end

    def method_missing(method, *args)
      return request.send(method, args) if %i[get post delete put].include?(method)
      append_chain(method, args)
      self
    end

    def retries(number)
      @retries = number
      self
    end

    def execute_request(options)
      tries_remaining = @retries
      begin
        RestClient::Request.execute(options)
      rescue RestClient::Exceptions::OpenTimeout
        if tries_remaining > 0
          logger.debug "Timeout while accessing API #{@resource.instance_variable_get(:@url)}. Tries remaining: #{tries_remaining}"
          tries_remaining -= 1
          retry
        end
        raise
      end
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

        options.merge!(
          **kwargs,
          method: method,
          url: @resource.send(:concat_urls, url, @query.join('/')),
          payload: payload
        )

        result = execute_request(options)

        ::Dcim::ApiResult.new(result)
      end
    end
  end
end
