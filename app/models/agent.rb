class Agent < ApplicationRecord
  has_many :agent_properties
  has_many :component_agents
  has_many :components, through: :component_agents
  has_many :actions
  belongs_to :delegate, optional: true
end
