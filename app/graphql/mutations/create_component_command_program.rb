module Mutations
  class CreateComponentCommandProgram < Mutations::BaseMutation
    argument :program, [Types::ComponentCommandType], required: true

    field :interpreted_program, GraphQL::Types::JSON, null: true
    field :errors, [String], null: false

    def resolve(plan:)
      {
          interpreted_program: 'TODO',
          errors: []
      }
    end

    def interpret_program(plan)
      output = {}
      plan.each do |action|
        step = action[:step].to_i
        action.delete(:step)
        output[step] ||= Set.new
        output[step].add(action)
      end
      output
    end
  end
end
