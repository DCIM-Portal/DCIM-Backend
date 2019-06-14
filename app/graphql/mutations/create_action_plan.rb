module Mutations
  class CreateActionPlan < Mutations::BaseMutation
    argument :plan, [Types::ActionType], required: true

    field :action_plan, GraphQL::Types::JSON, null: true
    field :errors, [String], null: false

    def resolve(plan:)
      plan.each do |action|
        component_id = action[:component_id]
        step = action[:step]
        command = action[:command]
        Rails.logger.warn(
          component_id: component_id,
          step: step,
          command: command
        )
      end
      {
        action_plan: 'TODO',
        errors: []
      }
    end
  end
end
