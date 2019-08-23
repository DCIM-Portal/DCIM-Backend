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
    command = task['command']
    command_arguments = task['command_arguments']

    component = Component.find(component_id)
    agents = component.agents
    drivers = agents.map(&:driver).filter { |driver| driver.is_a?(Dcim::Drivers::ApplicationDriver) }
    sorted_drivers = preferred_drivers(drivers, component, command)

    sorted_drivers.each do |driver|
      driver.run_command(command, command_arguments)
      break
    rescue StandardError => e
      Rails.logger.warn(
        "Driver #{driver} failed to run #{command} on #{component.class.name} ID #{component.id}: " \
      "#{e.message}"
      )
    end
  end

  # Get a list of supported and preferred drivers in descending order of preference
  # @param [Array<ApplicationDriver>] driver_list List of candidate Drivers in no particular order
  # @param [Component] component Component on which the command is to be applied
  # @param [Symbol] command Desired command to be run by a Driver
  # @return [Array] List of supported Drivers in descending preferred order
  def preferred_drivers(driver_list, component, command)
    driver_list.map! do |driver|
      command_runner_class = driver.command_runner_class(component)
      weight = command_runner_class.preference_of(command)
      [driver, weight]
    end
    driver_weights = driver_list.select { |_driver, weight| weight.positive? }
    driver_weights.sort_by { |_driver, weight| weight }.reverse.map { |driver, _weight| driver }
  end
end
