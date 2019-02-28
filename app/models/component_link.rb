class ComponentLink < ApplicationRecord
  belongs_to :component
  belongs_to :linked_component, class_name: 'Component'

  after_create :create_inverse_link, unless: :inverse_link?
  after_destroy :destroy_inverse_links, if: :inverse_link?

  def inverse_link_match_options
    { component_id: linked_component_id, linked_component_id: component_id }
  end

  def inverse_links
    self.class.where(inverse_link_match_options)
  end

  def inverse_link?
    self.class.exists?(inverse_link_match_options)
  end

  def create_inverse_link
    inverse = dup
    inverse.update(inverse_link_match_options)
  end

  def destroy_inverse_links
    inverse_links.destroy_all
  end
end