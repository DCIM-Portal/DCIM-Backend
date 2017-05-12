module AssetManager

  class ApiResult
    def initialize(result)
      @result = result
    end
    def to_str
      @result.body
    end
    def to_hash(key)
      JSON.parse(self)
    end
    def [](key)
      self.to_hash[key]
    end
  end

end
