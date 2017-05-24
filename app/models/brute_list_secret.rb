class BruteListSecret < ApplicationRecord
  belongs_to :brute_list
  validates :username, :password, :order, presence: true
end
