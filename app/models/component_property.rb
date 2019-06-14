class ComponentProperty < ApplicationRecord
  belongs_to :component
  belongs_to :source, class_name: 'Agent', optional: true
end
