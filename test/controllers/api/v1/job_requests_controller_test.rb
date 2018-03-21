require 'test_helper'

class Api::V1::JobRequestsControllerTest < ActionDispatch::IntegrationTest
  test 'execute starts job' do
    request = bmc_scan_requests(:one)
    output = 'OUTPUT'
    job = stub_everything('BmcScanJob', job_id: output)
    BmcScanJob.expects(:perform_later).returns(job)
    post execute_api_v1_bmc_scan_request_url(id: request),
         headers: authenticated_header
    assert_response :success
    assert_equal output, JSON.parse(@response.body)['data']['job_id']
  end
end
