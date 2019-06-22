class LoggableEvent < ApplicationRecord
  # XXX: Constraints in SQL to ensure LoggableEvent is deleted along with its Loggable
  belongs_to :loggable, polymorphic: true
  belongs_to :event
end
