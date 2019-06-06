class Component < ApplicationRecord
  has_many :children, class_name: Component.name, foreign_key: :parent_id
  belongs_to :parent, class_name: Component.name, optional: true
  has_many :properties, class_name: ComponentProperty.name
  has_many :component_links
  has_many :linked_components, through: :component_links
  has_many :component_agents
  has_many :agents, through: :component_agents

  before_destroy :give_children_to_parents

  private

  def give_children_to_parents
    children.each do |child|
      child.parent = parent
      child.save!
    end
  end
end
