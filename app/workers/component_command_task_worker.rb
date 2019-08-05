class ComponentCommandTaskWorker < TaskWorker
  # @param [Hash] task The sanitized ComponentCommand to execute
  # @option task [String] "component_id" ID of the Component on which to run the command
  # @option task [Integer] "step" Sequential step number for this ComponentCommand
  # @option task [String] "command" What to do to the Component
  # @option task [Hash, Array, String] "command_arguments" Arguments to the command, if needed
  # @option task [Integer] "command_timeout" Override the command's timeout, in seconds
  # @option task [Integer] "command_retries" Override the number of retries per Driver for the command
  # @option task [Boolean] "ignore_errors" Set to true if failure of this ComponentCommand is allowed
  # @option task [Array<String>] "driver_order" List of preferred Drivers to try in sequential order
  # @option task [Boolean] "only_use_specified_drivers" True if only the Drivers in "driver_order" should be tried
  # @see Types::ComponentCommandType
  def perform(task)
    component_id = task['component_id']
    _component = Component.find(component_id)
    # TODO
  end

  # @param [Array<Driver>] driver_list List of candidate Drivers
  # @param [Component] component Component on which the command is to be applied
  # @param [String] command Desired command to be run by a Driver
  # @return [Array] List of supported Drivers in descending preferred order
  def preferred_drivers(driver_list, component, command)
    driver_list.each do |driver|
    end
  end
end
