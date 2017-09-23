class BruteList < ApplicationRecord
  has_many :brute_list_secrets, dependent: :destroy
  has_many :bmc_scan_requests, autosave: true, dependent: :restrict_with_exception
  accepts_nested_attributes_for :brute_list_secrets, reject_if: :all_blank, allow_destroy: true
  validates :name, presence: true
  validates_uniqueness_of :name
end
