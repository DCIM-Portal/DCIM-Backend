module Dcim
  class BaseApi
    def initialize(**kwargs)
      create_resource(**kwargs)
    end

    def create_resource(**kwargs)
      url = kwargs.delete(:url)
      @resource = RestClient::Resource.new(url, **kwargs)
    end

    def retries(number)
      @retries = number
      self
    end

    def method_missing(method, *args)
      Dcim::ApiQuery.new(resource: @resource, method: method, args: args, retries: @retries)
    end

    def query
      method_missing(nil)
    end
  end
end
