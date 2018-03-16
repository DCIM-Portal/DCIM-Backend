class Zone < ApplicationRecord
  include Searchable

  has_many :bmc_hosts, autosave: true, dependent: :restrict_with_exception
  has_many :bmc_scan_requests, autosave: true, dependent: :restrict_with_exception
  has_many :enclosure_racks, autosave: true, dependent: :restrict_with_exception

  has_many :children, class_name: 'Zone', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Zone', foreign_key: :parent_id, optional: true

  validates :name, presence: true
  validates_uniqueness_of :name
end
