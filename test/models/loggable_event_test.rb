require 'test_helper'

class LoggableEventTest < ActiveSupport::TestCase
  def assert_dependent_destroy(loggable, loggable_event)
    assert_includes(loggable.loggable_events, loggable_event)
    assert loggable_event.reload

    loggable.destroy!

    assert loggable.destroyed?
    assert_raises ActiveRecord::RecordNotFound do
      loggable_event.reload
    end
  end

  test 'deleting a Component deletes associated LoggableEvent' do
    loggable_event = loggable_events(:component_loggable_event)
    component = components(:"c2218566-e181-4e5e-a20e-dc641ca97533")

    assert_dependent_destroy(component, loggable_event)
  end

  test 'deleting an Agent deletes associated LoggableEvent' do
    loggable_event = loggable_events(:agent_loggable_event)
    agent = agents(:dummy_agent)

    assert_dependent_destroy(agent, loggable_event)
  end

  test 'deleting a JobRun deletes associated LoggableEvent' do
    loggable_event = loggable_events(:job_run_loggable_event)
    job_run = job_runs(:some_job_run)

    assert_dependent_destroy(job_run, loggable_event)
  end
end
