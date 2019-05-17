class ComponentProperty < ApplicationRecord
  belongs_to :component
  belongs_to :source, class_name: Agent.name, optional: true
end
