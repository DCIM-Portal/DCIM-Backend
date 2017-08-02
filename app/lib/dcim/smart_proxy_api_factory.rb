module Dcim

  module SmartProxyApiFactory

    extend self
    @smart_proxies = {}

    def instance(location_id)
      begin
        smart_proxy_resource = @smart_proxies[:location_id]
        raise Dcim::InvalidSmartProxyError unless smart_proxy_resource.is_a? Dcim::SmartProxyApi
        raise Dcim::InvalidSmartProxyError unless smart_proxy_resource.features.get.to_hash.include? "onboard"
        return @smart_proxies[:location_id]
      rescue RuntimeError
        return @smart_proxies[:location_id] = find_onboard_smart_proxy(location_id)
      end
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
      raise Dcim::InvalidSmartProxyError unless location["smart_proxies"].is_a?(Array)
      location["smart_proxies"].each do |smart_proxy|
        begin
          smart_proxy_resource = Dcim::SmartProxyApi.new(url: smart_proxy["url"])
        rescue RuntimeError => e
          logger.debug "Smart Proxy " + smart_proxy["url"] + " resource initialization error: " + e.message
          next
        end
        begin
          if smart_proxy_resource.features.get.to_hash.include? "onboard"
            logger.debug "Suitable Smart Proxy found: " + smart_proxy["url"]
            return smart_proxy_resource
          end
        rescue RuntimeError => e
          logger.warn "Smart Proxy " + smart_proxy["url"] + " error: " + e.message
        end
        logger.debug "Smart Proxy " + smart_proxy["url"] + " not suitable because it does not have the \"onboard\" feature"
      end
      raise Dcim::InvalidSmartProxyError
    end

  end

end
