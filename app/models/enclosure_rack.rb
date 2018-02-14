class EnclosureRack < ApplicationRecord
  attr_accessor :amount, :start_at, :zero_pad_to
  belongs_to :zone
  has_many :enclosures
  validates :name, uniqueness: { scope: :zone }
  validates :orientation, inclusion: 0..359
  validates :height, numericality: { greater_than: 0, less_than: 71 }
end
