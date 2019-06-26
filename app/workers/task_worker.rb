class TaskWorker
  include Sidekiq::Worker

  def perform(task)
    raise NotImplementedError, 'No implementation for this Task'
  end
end
