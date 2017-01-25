require 'test_helper'

class IloScanJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ilo_scan_job = ilo_scan_jobs(:one)
  end

  test "should get index" do
    get ilo_scan_jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_ilo_scan_job_url
    assert_response :success
  end

  test "should create ilo_scan_job" do
    assert_difference('IloScanJob.count') do
      post ilo_scan_jobs_url, params: { ilo_scan_job: { end_ip: @ilo_scan_job.end_ip, ilo_password: @ilo_scan_job.ilo_password, ilo_username: @ilo_scan_job.ilo_username, start_ip: @ilo_scan_job.start_ip, status: @ilo_scan_job.status } }
    end

    assert_redirected_to ilo_scan_job_url(IloScanJob.last)
  end

  test "should show ilo_scan_job" do
    get ilo_scan_job_url(@ilo_scan_job)
    assert_response :success
  end

  test "should get edit" do
    get edit_ilo_scan_job_url(@ilo_scan_job)
    assert_response :success
  end

  test "should update ilo_scan_job" do
    patch ilo_scan_job_url(@ilo_scan_job), params: { ilo_scan_job: { end_ip: @ilo_scan_job.end_ip, ilo_password: @ilo_scan_job.ilo_password, ilo_username: @ilo_scan_job.ilo_username, start_ip: @ilo_scan_job.start_ip, status: @ilo_scan_job.status } }
    assert_redirected_to ilo_scan_job_url(@ilo_scan_job)
  end

  test "should destroy ilo_scan_job" do
    assert_difference('IloScanJob.count', -1) do
      delete ilo_scan_job_url(@ilo_scan_job)
    end

    assert_redirected_to ilo_scan_jobs_url
  end
end
