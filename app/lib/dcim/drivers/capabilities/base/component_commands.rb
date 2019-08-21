module Dcim
  module Drivers
    module Capabilities
      module Base
        class ComponentCommands
          class << self
            attr_reader :preferences
          end

          def self.preference_of(method_name)
            @preferences[method_name.to_sym] || 0
          end

          def self.method_added(method)
            @preferences ||= {}
            @preferences[method] = @_last_preference if @_last_preference
            @_last_preference = nil
          end

          def self.method_missing(method, *args)
            return super unless method == :preference

            @_last_preference = args[0]
          end

          def self.respond_to_missing?(method)
            return false unless method == :preference

            true
          end
        end
      end
    end
  end
end
