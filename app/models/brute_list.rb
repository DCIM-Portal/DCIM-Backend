class BruteList < ApplicationRecord
  has_many :brute_list_secrets, :dependent => :destroy
  accepts_nested_attributes_for :brute_list_secrets, reject_if: :all_blank, allow_destroy: true
  validates :name, presence: true
  validates_uniqueness_of :name
end
