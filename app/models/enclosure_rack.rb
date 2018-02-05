class EnclosureRack < ApplicationRecord
  attr_accessor :amount, :start_at
  belongs_to :zone
  has_many :enclosures
  validates :name, uniqueness: { scope: :zone }
  validates :orientation, inclusion: 0..359
end
