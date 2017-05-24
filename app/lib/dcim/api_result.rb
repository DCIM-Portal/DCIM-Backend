module Dcim 

  class ApiResult

    def initialize(result)
      @result = result
    end

    def method_missing(method, *args)
      @result.send(method, *args)
    end
  
    def to_str
      @result.body
    end

    def to_hash
      JSON.parse(self)
    end

    def [](key)
      self.to_hash[key]
    end

  end

end
