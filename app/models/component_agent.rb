class ComponentAgent < ApplicationRecord
  belongs_to :component
  belongs_to :agent
end