module Dcim

  class Api
    def method_missing(method, *args)
      ::Dcim::ApiQuery.new(resource: @resource, method: method, args: args)
    end
  end

end
