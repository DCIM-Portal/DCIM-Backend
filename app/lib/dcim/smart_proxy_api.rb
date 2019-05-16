module Dcim
  class SmartProxyApi < BaseApi
    def initialize(**kwargs)
      create_resource(kwargs)
    end

    def create_resource(**kwargs)
      cert =  Rails.configuration.smart_proxy['cert']
      ca_cert = Rails.configuration.smart_proxy['ca_cert']
      privkey = Rails.configuration.smart_proxy['privkey']
      super(
          **kwargs,
          proxy: '',
          read_timeout: kwargs[:read_timeout] || kwargs[:timeout] || 30,
          open_timeout: kwargs[:open_timeout] || kwargs[:timeout] || 5,
          ssl_ca_file: ca_cert,
          ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(cert)),
          ssl_client_key: OpenSSL::PKey::RSA.new(File.read(privkey)),
          verify_ssl: OpenSSL::SSL::VERIFY_PEER
      )
    end
  end
end
