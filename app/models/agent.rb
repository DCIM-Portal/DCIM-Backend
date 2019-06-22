class Agent < ApplicationRecord
  has_many :agent_properties, dependent: :destroy
  has_many :component_agents, dependent: :destroy
  has_many :components, through: :component_agents
  belongs_to :delegate, optional: true
  has_many :loggable_events, as: :loggable, dependent: :destroy
  has_many :events, through: :loggable_events
end
