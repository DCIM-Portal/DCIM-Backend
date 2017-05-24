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
      self.append_chain(method, args)
      self
    end

    def get
      ApiResult.new(@resource[@query.join("/")].get)
    end

    def post(payload)
      ApiResult.new(@resource[@query.join('/')].post(payload.to_json, {'Content-Type':'application/json'}))
    end

  end

end
