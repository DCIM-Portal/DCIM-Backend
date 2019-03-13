module Types
  class ComponentPropertyType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :key, String, null: true
    field :value, String, null: true
    field :component, ComponentType, null: true
  end
end
