module Mutations
  class CreateComponentCommandProgram < Mutations::BaseMutation
    argument :program, [Types::ComponentCommandType], required: true

    field :interpreted_program, GraphQL::Types::JSON, null: true
    field :errors, [String], null: false

    def resolve(program:)
      interpreted_program = interpret_program(program)
      job_run = JobRun.new(
        type: 'ProgramJobRun',
        arguments: interpreted_program
      )
      ProgramJob.perform_later job_run
      {
        job_run_id: job_run.id,
        interpreted_program: interpreted_program,
        errors: []
      }
    end

    def interpret_program(program)
      output = {}
      program.each do |action|
        # TODO: Sanitize input, restrict with permissions
        action = HashWithIndifferentAccess[action]
        step = action[:step].to_i
        action.delete(:step)
        output[step] ||= Set.new
        output[step].add(action)
      end
      output
    end
  end
end
