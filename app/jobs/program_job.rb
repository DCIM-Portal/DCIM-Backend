class ProgramJob < ApplicationJob
  queue_as :default

  TASK_WORKER = TaskWorker

  # @param [ProgramJobRun] job_run The JobRun with an argument that is an interpreted program
  # @param [Integer] previous_step The step that was completed prior to calling this method
  def perform(job_run, previous_step = nil)
    program = job_run.arguments
    program.transform_keys!(&:to_i)
    steps = program.keys.sort
    current_step = if previous_step.nil?
                     job_run.update!(status: :in_progress)
                     steps.first
                   else
                     steps[steps.index(previous_step) + 1]
                   end
    return cleanup(job_run) if current_step.nil?

    batch = Sidekiq::Batch.new
    batch.on(
      :success,
      "#{self.class.name}#on_step_complete",
      job_run: job_run,
      previous_step: current_step
    )
    batch.jobs do
      tasks = program[current_step]
      tasks.each do |task|
        task_worker_class.perform_async(task)
      end
    end
  end

  # @return [TaskWorker] Class of the implementation of TaskWorker for this ProgramJob
  def self.task_worker_class
    TASK_WORKER
  end

  # @param [Sidekiq::Batch::Status] status
  # @param [Hash] options Arguments to send to the next #perform step
  def self.on_step_complete(status, options)
    if status.failures != 0
      options[:job_run].update!(status: :failed)
      return
    end
    perform_now(options[:job_run], options[:previous_step])
  end

  # Clean up after all steps are completed
  # @param [ProgramJobRun] job_run
  def self.cleanup(job_run)
    job_run.update!(status: :succeeded)
  end
end
