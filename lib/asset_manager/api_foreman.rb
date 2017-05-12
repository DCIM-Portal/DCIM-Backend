module AssetManager

  class ForemanApi < Api
    def initialize(**kwargs)
      create_resource(kwargs)
    end
    def create_resource(**kwargs)
      @resource = RestClient::Resource.new(kwargs[:url], proxy: "", user: kwargs[:username], password: kwargs[:password], verify_ssl: false)   
    end
  end

end
