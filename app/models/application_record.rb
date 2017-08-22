class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  after_commit :emit_cable

  def emit_cable(**kwargs)
    ::LiveViewBroadcastJob.perform_now self, **kwargs
  end
end
