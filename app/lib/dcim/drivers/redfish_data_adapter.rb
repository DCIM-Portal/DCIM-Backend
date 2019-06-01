module Dcim
  module Drivers
    class RedfishDataAdapter
      class << self
        def adapt(raw_value, property_key, component)
          send("adapt_#{component.class.name.downcase}_#{property_key.downcase}", raw_value)
        end

        def method_missing(method, *args)
          return args[0] if args.length == 1

          super
        end

        def respond_to_missing?(method)
          return true if args.length == 1

          super
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
