module Types
  class MutationType < Types::BaseObject
    field :update_component, mutation: Mutations::UpdateComponent
    field :create_action_plan, mutation: Mutations::CreateActionPlan
  end
end
