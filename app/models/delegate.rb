class Delegate < ApplicationRecord
  has_many :agents, dependent: :restrict_with_exception
end
