module Dcim
  class BasicAuthApi < BaseApi
    def create_resource(**kwargs)
      username = kwargs.delete(:username)
      password = kwargs.delete(:password)
      super(
          **kwargs,
          user: username,
          password: password
      )
    end
  end
end
