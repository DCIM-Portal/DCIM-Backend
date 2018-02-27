module Dcim
  module ForemanApiFactory
    module_function

    def instance
      username = Rails.configuration.foreman['username']
      password = Rails.configuration.foreman['password']
      url = Rails.configuration.foreman['url']
      @foreman_resource ||= ForemanApi.new(url: url, username: username, password: password)
    end

    def unauthenticated_instance
      ForemanApi.new(url: Rails.configuration.foreman['url'])
    end
  end
end
