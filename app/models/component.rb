class Component < ApplicationRecord
  has_many :children, class_name: Component.name, foreign_key: :parent_id
  belongs_to :parent, class_name: Component.name, optional: true
end
