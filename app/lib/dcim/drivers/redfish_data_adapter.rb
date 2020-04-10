module Dcim
  module Drivers
    class RedfishDataAdapter
      class << self
        def adapt(raw_value, property_key, component, component_data)
          method_name = "adapt_#{component.class.name.downcase}_#{property_key.downcase}"
          return raw_value unless respond_to?(method_name)

          if method(method_name).parameters.length == 2
            send(method_name, raw_value, component_data)
          else
            send(method_name, raw_value)
          end
        end

        def adapt_diskcomponent_capacitylogicalblocks(raw_value, component_data)
          block_size = component_data["BlockSizeBytes"] || 512
          raw_value.to_i * block_size
        end

        def adapt_ramcomponent_capacitymib(raw_value)
          raw_value.to_i * 1024 * 1024
        end

        def adapt_ramcomponent_sizemb(raw_value)
          raw_value.to_i * 1000 * 1000
        end
      end
    end
  end
end
