require 'test_helper'

class GraphQlCreateComponentCommandProgramTest < ActionDispatch::IntegrationTest
  test 'the truth' do
    query_string = <<-GRAPHQL
    mutation createComponentCommandProgram($plan: [Action!]!) {
      createComponentCommandProgram(plan: $plan) {
        program
        errors
      }
    }
    GRAPHQL
    program = [
      {
        componentId: 'my component id',
        step: 2,
        command: 'power_on'
      },
      {
        componentId: 'my component id',
        step: 1,
        command: 'power_off'
      },
      {
        componentId: 'my component id 2',
        step: 2,
        command: 'power_reset'
      }
    ]

    create_component_command_program_result = DcimPortalSchema.execute(query_string, variables: {program: program })
    Rails.logger.warn(create_component_command_program_result)
  end
end
