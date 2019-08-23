module Dcim
  module Drivers
    class ApplicationDriver
      COMMAND_RUNNER_CLASS_SUFFIX = 'Commands'.freeze

      # @param [Agent] agent The driver's connection agent, containing authentication information
      def initialize(agent)
        @agent = agent
        @properties = {}
        @agent.agent_properties.each do |agent_property|
          @properties.merge!(agent_property.key.to_sym => agent_property.value)
        end
      end

      # Get Dcim::Drivers::Capabilities module for this Driver
      def capabilities_module
        Capabilities.const_get(self.class.name.demodulize)
      end

      # Return a set of component types that this driver can support
      def supported_components
        capabilities_module
          .constants
          .select { |constant| constant.to_s.ends_with? COMMAND_RUNNER_CLASS_SUFFIX }
          .map do |component_command_name|
          component_command_name
            .to_s
            .gsub(/#{COMMAND_RUNNER_CLASS_SUFFIX}$/, '')
            .constantize
        end
      end

      # Return the ComponentCommands class for this Component
      # @return [Dcim::Drivers::Capabilities::Base::ComponentCommands, nil]
      def command_runner_class(component)
        capabilities_module.const_get(
          "#{component}#{COMMAND_RUNNER_CLASS_SUFFIX}"
        )
      rescue NameError
        nil
      end

      # Return a set of methods that this driver can provide to the component
      def supported_commands(component)
        commands_class = command_runner_class(component)
        return [] if commands_class.nil?

        commands_class.preferences.select { |_key, value| value.positive? }.keys
      end

      # Check if the provided command is in the supported commands list
      def command_supported?(component, command)
        supported_commands(component).include? command
      end

      # Execute a command
      #
      # @param [Component] component The component on which the command should be run
      # @param [String] command The command to run
      # @param [Hash] kwargs
      # @option kwargs [String] :value Main argument to the command
      def run_command(component, command, **kwargs)
        klass = command_runner_class(component)
        raise Dcim::NoSuchMethodError, "No command runner for #{component.class.name}" if klass.nil?

        command_runner = klass.new(self)
        if command_runner.method(command).arity != 0
          command_runner.send(command, kwargs)
        else
          command_runner.send(command)
        end
      end
    end
  end
end
