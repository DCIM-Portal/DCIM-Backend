module Types
  class ComponentType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :type, String, null: true
    field :label, String, null: true
    field :managed, Boolean, null: false
    field :parent, ComponentType, null: true
    field :children, [ComponentType], null: true
    field :properties, [ComponentPropertyType], null: true
  end
end