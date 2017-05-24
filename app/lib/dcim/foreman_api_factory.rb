module Dcim

  module ForemanApiFactory

    extend self

    def instance 
      username = Rails.configuration.foreman['username']
      password = Rails.configuration.foreman['password']
      url = Rails.configuration.foreman['url']
      @foreman_resource ||= ForemanApi.new(url: url, username: username, password: password)
    end
  
  end

end
