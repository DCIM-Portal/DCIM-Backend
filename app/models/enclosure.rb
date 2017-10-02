class Enclosure < ApplicationRecord
  belongs_to :enclosure_rack, optional: true
  has_many :devices
end
