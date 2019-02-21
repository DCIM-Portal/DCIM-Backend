module Dcim
  module SmartProxyApiFactory
    module_function

    @smart_proxies = {}

    def instance(location_id)
      smart_proxy_resource = @smart_proxies[location_id]
      raise Dcim::InvalidSmartProxyError unless smart_proxy_resource.is_a? Dcim::SmartProxyApi
      raise Dcim::InvalidSmartProxyError unless smart_proxy_resource.features.get.to_hash.include? 'onboard'

      logger.debug "Returning cached Smart Proxy for Foreman location ID #{location_id} because it is still suitable"
      @smart_proxies[location_id]
    rescue RuntimeError
      logger.debug "No Smart Proxy currently cached for Foreman location ID #{location_id}"
      @smart_proxies[location_id] = find_onboard_smart_proxy(location_id)
    end

    def unset(location_id)
      @smart_proxies[:location_id] = nil
    end

    def unset_all
      @smart_proxies = {}
    end

    def logger
      @logger ||= Rails.logger
    end

    def find_onboard_smart_proxy(location_id)
      logger.debug "Getting Smart Proxies list from Foreman location ID #{location_id}..."
      location = Dcim::ForemanApiFactory.instance.api.locations(location_id).get.to_hash
      raise Dcim::InvalidSmartProxyError unless location['smart_proxies'].is_a?(Array)

      location['smart_proxies'].each do |smart_proxy|
        begin
          smart_proxy_resource = Dcim::SmartProxyApi.new(url: smart_proxy['url'])
        rescue RuntimeError => e
          logger.debug 'Smart Proxy ' + smart_proxy['url'] + ' resource initialization error: ' + e.message
          next
        end
        begin
          if smart_proxy_resource.features.get.to_hash.include? 'onboard'
            logger.debug 'Suitable Smart Proxy found: ' + smart_proxy['url']

            # Send back a Smart Proxy resource with longer timeouts
            # XXX: Fine-grained timeouts?
            return Dcim::SmartProxyApi.new(url: smart_proxy['url'], open_timeout: 30, read_timeout: 60)
          end
        rescue RuntimeError => e
          logger.warn 'Smart Proxy ' + smart_proxy['url'] + ' error: ' + e.message
        end
        logger.debug 'Smart Proxy ' + smart_proxy['url'] + ' is not suitable because it does not have the "onboard" feature'
      end
      raise Dcim::InvalidSmartProxyError
    end
  end
end
