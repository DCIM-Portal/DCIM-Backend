module Types
  class MutationType < Types::BaseObject
    field :update_component, mutation: Mutations::UpdateComponent
  end
end
