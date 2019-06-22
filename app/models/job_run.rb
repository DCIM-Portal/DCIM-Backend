class JobRun < ApplicationRecord
  has_many :loggable_events, as: :loggable, dependent: :destroy
  has_many :events, through: :loggable_events
  enum status: {
    not_running: 0,
    in_progress: 1,
    succeeded: 2,
    failed: 3
  }
end
