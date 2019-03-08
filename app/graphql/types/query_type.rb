module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :components, [Types::ComponentType], null: false do
      description "Get Components collection"
      argument :label, String, required: false
    end

    field :component, Types::ComponentType, null: true do
      description "Get one Component"
      argument :id, ID, required: true
    end

    field :component_property, Types::ComponentPropertyType, null: true do
      description "Get one ComponentProperty"
      argument :id, ID, required: true
    end

    def components(label: nil)
      if label.nil?
        Component.all
      else
        Component.where(label: label)
      end
    end

    def component(id:)
      Component.find(id)
    end

    def component_property(id:)
      ComponentProperty.find(id)
    end
  end
end
