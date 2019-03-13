module Mutations
  class UpdateComponent < BaseMutation
    argument :id, ID, required: true
    argument :label, String, required: false
    argument :managed, Boolean, required: false

    field :component, Types::ComponentType, null: true
    field :errors, [String], null: false

    def resolve(**kwargs)
      component = Component.find(kwargs[:id])
      if component.update(**kwargs)
        {
          component: component,
          errors: []
        }
      else
        {
          component: nil,
          errors: component.errors.full_messages
        }
      end
    end
  end
end
