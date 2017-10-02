class Device < ApplicationRecord
  belongs_to :target, polymorphic: true
  belongs_to :enclosure
  has_many :device_links
  has_many :linked_devices, through: :device_links
end
