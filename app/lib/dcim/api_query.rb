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
      define_method(method) do |*args|
        rest_query = @resource[@query.join('/')]
        if args.length > 0
          args << {'Content-Type':'application/json'}
          args[0] = args[0].to_json
        end
        result = rest_query.send(method, *args)
        ApiResult.new(result)
      end
    end
   
  end

end
