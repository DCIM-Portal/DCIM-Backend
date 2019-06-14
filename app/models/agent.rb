class Agent < ApplicationRecord
  has_many :agent_properties, dependent: :destroy
  has_many :component_agents, dependent: :destroy
  has_many :components, through: :component_agents
  has_many :actions, dependent: :nullify
  belongs_to :delegate, optional: true
end
