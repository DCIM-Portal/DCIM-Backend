class EnclosureRack < ApplicationRecord
  belongs_to :zone
  has_many :enclosures
  validates :name, uniqueness: true
  validates :orientation, inclusion: 0..359
end
