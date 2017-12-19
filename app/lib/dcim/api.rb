module Dcim
  class Api
    def retries(number)
      @retries = number
      self
    end

    def method_missing(method, *args)
      Dcim::ApiQuery.new(resource: @resource, method: method, args: args, retries: @retries)
    end
  end
end
