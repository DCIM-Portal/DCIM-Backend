module Dcim
  class ForemanApi < BasicAuthApi
    def create_resource(**kwargs)
      super(
          **kwargs,
          proxy: '',
          timeout: 10,
          open_timeout: 5,
          verify_ssl: false
      )
    end
  end
end
