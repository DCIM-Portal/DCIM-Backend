require 'test_helper'
require_relative '../../app/lib/dcim/exception'

class OnboardJobTest < ActiveJob::TestCase
  setup do
    @mock_foreman_resource = Dcim::ForemanApi.new
#    @mock_request = OnboardRequest.new
    @mock_request = mock('object')
    @mock_request.bmc_host = BmcHost.new
#    @onboard_job = OnboardJob.new(foreman_resource: @mock_foreman_resource,
#                                  request: @mock_request)
    @onboard_job = OnboardJob.new
    @onboard_job.store_dependencies(foreman_resource: @mock_foreman_resource,
                                    request: @mock_request)
  end

  test "store_dependencies stores injected dependencies" do
    assert_equal @onboard_job.instance_variable_get(:@foreman_resource), @mock_foreman_resource, "Foreman resource dependency not stored"
    assert_equal @onboard_job.instance_variable_get(:@request), @mock_request, "Request dependency not stored"
  end

  test "keep trying for every y seconds until bool z stub x" do
    x = lambda { mock('object').some_method }
    y = 5
    z = true
    x.expects(:call).times(37).returns(*Array.new(36, !z)).then.returns(z)
    @onboard_job.expects(:sleep).times(36).with(y)
    @onboard_job.keep_trying(every: y, until: z, &x)
  end

  test "keep trying timeout and call x block" do
    object = mock('object')
    x = lambda { object.some_method }
    z = false
    timeout = 10
    Timeout::expects(:timeout).with(10).yields(x)
    object.expects(:some_method).times(37).returns(*Array.new(36, !z)).then.returns(z)
    @onboard_job.expects(:sleep).times(36)
    @onboard_job.keep_trying(every: 1, until: z, timeout: timeout, &x)
  end

  test "keep trying x block flunks timeout" do
    timeout = 15
    Timeout::expects(:timeout).with(timeout).raises(Timeout::Error)
    assert_raises(Timeout::Error) { @onboard_job.keep_trying(every: 1, until: true, timeout: timeout, &lambda{}) }
  end

  test "shutdown returns not false" do
    object = mock('object')
    object.expects(:shutdown).returns true
    @mock_request.expects(:bmc_host).returns object
    assert @onboard_job.shutdown != false, "Shutdown returned false, but should have raised an exception instead"
  end

  test "shutdown raises RuntimeError" do
    object = mock('object')
    object.expects(:shutdown).raises Dcim::InvalidSmartProxyError
    @mock_request.expects(:bmc_host).returns object
    assert_raises RuntimeError do
      @onboard_job.shutdown
    end
  end

  test "power_off returns not false" do
    object = mock('object')
    object.expects(:power_off).returns true
    @mock_request.expects(:bmc_host).returns object
    assert @onboard_job.power_off != false, "Poweroff returned false, but should have raised an exception instead" 
  end

  test "power_off raises RuntimeError" do
    object = mock('object')
    object.expects(:power_off).raises Dcim::InvalidPasswordError
    @mock_request.expects(:bmc_host).returns object
    assert_raises RuntimeError do
      @onboard_job.power_off
    end
  end

  test "power_on_pxe returns not false" do
    object = mock('object')
    object.expects(:power_on_pxe).returns true
    @mock_request.expects(:bmc_host).returns object
    assert @onboard_job.power_on_pxe != false, "power_on_pxe returned false, but should have raised an exception instead" 
  end

  test "power_on_pxe raises RuntimeError" do
    object = mock('object')
    object.expects(:power_on_pxe).raises Dcim::InvalidPasswordError
    @mock_request.expects(:bmc_host).returns object
    assert_raises RuntimeError do
      @onboard_job.power_on_pxe
    end
  end

  test "powered on returns true" do
    object = mock('object')
    object.expects(:power_on?).returns true
    @mock_request.expects(:bmc_host).returns object
    assert_equal @onboard_job.power_on?, true, "Power is not on"
  end

  test "powered on raises RuntimeError" do
    object = mock('object')
    object.expects(:power_on?).raises Dcim::UnsupportedApiResponseError
    @mock_request.expects(:bmc_host).returns object
    assert_raises RuntimeError do
      @onboard_job.power_on?
    end
  end

  test "look up serial provides expected results" do
    response = {"results"=>{"ops-am2ops-gluster0001"=>{"serialnumber"=>"USE447ER2L"}}}
    BmcHost.any_instance.expects(:serial).returns("USE447ER2L")
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_equal @onboard_job.look_up_serial, response["results"], "Response does not match expected"
  end

  test "look up serial raises unsupported API response error if results not a Hash" do
    response = {"results"=>"this should not be a string!"}
    BmcHost.any_instance.expects(:serial).returns("USE447ER2L")
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_raises(Dcim::UnsupportedApiResponseError) { @onboard_job.look_up_serial }
  end

  test "look up serial raises unsupported API response error with invalid API response" do
    response = {"error"=>"this is totally unexpected"}
    BmcHost.any_instance.expects(:serial).returns("USE447ER2L")
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_raises(Dcim::UnsupportedApiResponseError) { @onboard_job.look_up_serial }
  end

  test "look up serial raises duplicate serial error with more than one result" do
    response = {"results"=>{"ops-am2ops-gluster0001"=>{"serialnumber"=>"USE447ER2L"},"ops-am2ops-gluster0002"=>{"serialnumber"=>"USE447ER2L"}}}
    BmcHost.any_instance.expects(:serial).returns("USE447ER2L")
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_raises(Dcim::DuplicateSerialError) { @onboard_job.look_up_serial }
  end

  test "check serial onboarded in Foreman if Foreman host is promoted" do
    response = {"results"=>{"ops-am2ops-gluster0001"=>{"serialnumber"=>"USE447ER2L"}}}
    @onboard_job.expects(:look_up_serial).returns(response)
    assert @onboard_job.serial_onboarded?, "Serial reported not found in Foreman when it should be"
  end

  test "check serial onboarded in Foreman if Foreman host is not promoted" do
    response = {"results"=>{""=>{"serialnumber"=>"USE447ER2L"}}}
    @onboard_job.expects(:look_up_serial).returns(response)
    assert @onboard_job.serial_onboarded?, "Serial reported not found in Foreman when it should be"
  end

  test "check serial not onboarded in Foreman" do
    response = {}
    @onboard_job.expects(:look_up_serial).returns(response)
    assert_not @onboard_job.serial_onboarded?, "Serial reported found in Foreman when it should not be"
  end

  test "serial to system name" do
    serial = "USE447ER2L"
    name = "ops-am2ops-gluster0001"
    response = {name=>{"serialnumber"=>serial}}
    @onboard_job.expects(:look_up_serial).returns(response)
    assert_equal @onboard_job.serial_to_system_name, name, "Correct name not returned"
  end

  test "serial to system name returns false if Foreman host is not promoted" do
    response = {"results"=>{""=>{"serialnumber"=>"USE447ER2L"}}}
    BmcHost.any_instance.expects(:serial).returns("USE447ER2L")
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_not @onboard_job.serial_to_system_name, "System name returned when there shouldn't be one"
  end

  test "serial to system name returns false if serial not onboarded in Foreman" do
    response = {}
    @onboard_job.expects(:look_up_serial).returns(response)
    assert_not @onboard_job.serial_to_system_name, "System name returned when there shouldn't be one"
  end

  test "system name to system id returns expected integer" do
    response = {"ip"=>"10.14.4.186", "id"=>"51"}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    result = @onboard_job.system_name_to_system_id('any-system-name')
    assert result.is_a?(Integer), "System ID is not an Integer"
    assert_equal result, 51, "Incorrect System ID returned"
  end

  test "system name to system id returns false if Foreman host name provided is false" do
    response = nil
    Dcim::ApiQuery.any_instance.stubs(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.stubs(:to_hash).returns(response)
    result = @onboard_job.system_name_to_system_id(false)
    assert_not result, "System ID unexpectedly returned"
  end

  test "system name to system id returns false if Foreman host name provided is blank string" do
    response = nil
    Dcim::ApiQuery.any_instance.stubs(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.stubs(:to_hash).returns(response)
    result = @onboard_job.system_name_to_system_id("")
    assert_not result, "System ID unexpectedly returned"
  end

  test "system name to system id returns false if Foreman host name is not provided" do
    response = nil
    Dcim::ApiQuery.any_instance.stubs(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.stubs(:to_hash).returns(response)
    result = @onboard_job.system_name_to_system_id(nil)
    assert_not result, "System ID unexpectedly returned"
  end
  
  test "system name to system id returns false if Foreman does not provide ID" do
    response = {"ip"=>"10.14.4.186", "not_id"=>51}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    result = @onboard_job.system_name_to_system_id("any-system-name")
    assert_not result, "System ID unexpectedly returned"
  end

  test "make new System from Foreman host ID" do
  end

  test "associate System to BmcHost" do
  end

  test "populate System with facts" do
  end

  test "reset step and status" do
    @mock_request.step = 1
    @mock_request.status = 1
    @mock_request.error_message = "this should disappear"
    @mock_request.save!
    @onboard_job.prepare_to_run
    assert_nil @mock_request.step, "Step should be undefined"
    assert_nil @mock_request.status, "Status should be undefined"
    assert_nil @mock_request.error_message, "Error message should be undefined"
  end

  [:shutdown, :power_off, :pxe, :discover, :manage, :bmc_creds].each do |item|
    test "start step #{item}" do
      @onboard_job.start_step(item)
      assert_equal @mock_request.step, "#{item}", "Step isn't correct"
      assert_equal @mock_request.status, "in_progress", "Status isn't in progress"
    end
  end

  test "store stack trace on job failure" do
    e = nil
    begin
      raise Dcim::UnsupportedApiResponseError
    rescue => e
    end
    msg = e.class.name + ": " + e.message + "\n" + e.backtrace.join("\n")
    @onboard_job.fail_with_error(e)
    assert_equal @mock_request.status, "stack_trace", "Status isn't error"
    assert_equal @mock_request.error_message, msg, "Error message wasn't recorded in expected format"
  end

  test "store timeout on job timeout" do
    e = nil
    begin
      raise Dcim::JobTimeoutError
    rescue => e
    end
    @onboard_job.fail_with_error(e)
    assert_equal @mock_request.status, "timeout", "Status isn't timeout"
  end

  test "finish job" do
    @onboard_job.finish_job
    assert_equal @mock_request.status, "success", "Status isn't success"
    assert_equal @mock_request.step, "complete", "Step isn't complete"
  end

#  test "successfully performs job" do
#    @onboard_job.perform
#    # TODO
#  end
end
