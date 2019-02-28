module Dcim
  module Drivers
    class ApplicationDriver
      # Return a set of component types that this driver can support
      def supported_components
        # TODO
      end

      # Return a set of methods that this driver can provide to the component
      def supported_commands(component)
        # TODO
      end

      # Execute a command
      #
      # @param command The command to run
      # @param **kwargs {
      #   value: Main argument to the command
      # }
      def run_command(command, **kwargs)
        # TODO
      end
    end
  end
end
