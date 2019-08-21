module Dcim
  module Drivers
    class ApplicationDriver
      COMPONENT_COMMANDS_SUFFIX = 'Commands'.freeze

      # @param [Agent] agent The driver's connection agent, containing authentication information
      def initialize(agent)
        @agent = agent
        @properties = {}
        @agent.agent_properties.each do |agent_property|
          @properties.merge!(agent_property.key.to_sym => agent_property.value)
        end
      end

      # Get DriverCapabilities module for this Driver
      def capabilities_module
        Capabilities.const_get(self.class.name.demodulize)
      end

      # Return a set of component types that this driver can support
      def supported_components
        capabilities_module
          .constants
          .select { |constant| constant.to_s.ends_with? COMPONENT_COMMANDS_SUFFIX }
          .map do |component_command_name|
            component_command_name
              .to_s
              .gsub(/#{COMPONENT_COMMANDS_SUFFIX}$/, '')
              .constantize
          end
      end

      # Return a set of methods that this driver can provide to the component
      def supported_commands(component)
        commands_class = capabilities_module.const_get(
          "#{component}#{COMPONENT_COMMANDS_SUFFIX}"
        )
        commands_class.preferences.select { |_key, value| value.positive? }.keys
      end

      # Execute a command
      #
      # @param [String] command The command to run
      # @param [Hash] kwargs
      # @option kwargs [String] :value Main argument to the command
      def run_command(command, **kwargs)
        # TODO
      end
    end
  end
end
