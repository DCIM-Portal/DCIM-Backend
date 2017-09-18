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

    def to_h
      JSON.parse(self)
    end
    def to_hash
      self.to_h
    end

    def [](key)
      self.to_h[key]
    end

  end

end
