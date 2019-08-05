module Types
  class ComponentCommandType < BaseInputObject
    description 'A single Component command in a program of Component commands'

    argument :component_id, String,
             'ID of the Component on which to run the command', required: true
    argument :step, Integer,
             'Sequential step number for this Component command. ' \
             'Actions with the same step number in a program may be executed in parallel.', required: true
    argument :command, String,
             'What to do to the Component', required: true
    argument :command_arguments, GraphQL::Types::JSON,
             'Arguments to the command, if needed', required: false
    argument :command_timeout, Integer,
             "Override the command's timeout, in seconds", required: false
    argument :command_retries, Integer,
             'Override the number of retries per Driver for the command', required: false
    argument :ignore_errors, Boolean,
             'Set to true if failure of this Component command is allowed', required: false
    argument :driver_order, [String],
             'List of preferred Drivers to try in sequential order', required: false
    argument :only_use_specified_drivers, Boolean,
             'Set to true if only the Drivers in the :driver_order argument should be tried', required: false
  end
end
