module Dcim

  class ForemanApi < Api
    def initialize(**kwargs)
      create_resource(kwargs)
    end
    def create_resource(**kwargs)
      @resource = RestClient::Resource.new(kwargs[:url], proxy: "", timeout: 10, open_timeout: 5, user: kwargs[:username], password: kwargs[:password], verify_ssl: false)   
    end
  end

end
