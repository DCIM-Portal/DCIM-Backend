require 'test_helper'

class ProgramJobTest < ActiveJob::TestCase
  setup do
    @job_run = JobRun.new(
        type: 'ProgramJobRun',
        arguments: {
            1 => %w[task1 task2],
            2 => %w[task3],
            4 => %w[task4 task5 task6]
        }
    )
  end

  test 'perform registers callback and runs first step' do
    ProgramJob.any_instance.expects(:task_worker_class).at_least_once.returns(TestTaskWorker)
    Sidekiq::Batch.any_instance.expects(:on).with(anything, anything, has_entry({previous_step: 1}))
    TestTaskWorker.expects(:perform_async).with('task1').returns(true)
    TestTaskWorker.expects(:perform_async).with('task2').returns(true)

    ProgramJob.perform_now(@job_run)
  end

  test 'on step complete starts next step' do
    status = stub_everything('Sidekiq::Batch::Status', :failures => 0)
    options = {
        job_run: @job_run,
        previous_step: 1
    }

    ProgramJob.any_instance.expects(:perform).with(@job_run, 1)

    ProgramJob.new(@job_run).on_step_complete(status, options)
  end

  test 'perform next step runs that next step' do
    ProgramJob.any_instance.expects(:task_worker_class).at_least_once.returns(TestTaskWorker)
    Sidekiq::Batch.any_instance.expects(:on).with(anything, anything, has_entry({previous_step: 4}))
    TestTaskWorker.expects(:perform_async).with('task4').returns(true)
    TestTaskWorker.expects(:perform_async).with('task5').returns(true)
    TestTaskWorker.expects(:perform_async).with('task6').returns(true)

    ProgramJob.perform_now(@job_run, 2)
  end

  test 'last step leads to cleanup' do
    ProgramJob.any_instance.expects(:cleanup)

    ProgramJob.perform_now(@job_run, 4)
  end
end

class TestTaskWorker < TaskWorker
end
