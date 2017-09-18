require 'test_helper'

class OnboardJobTest < ActiveJob::TestCase
  setup do
    @mock_foreman_resource = Dcim::ForemanApi.new
    @mock_request = OnboardRequest.new
    @mock_request.bmc_hosts << bmc_hosts(:one)
    @mock_request.bmc_hosts << bmc_hosts(:two)
    @onboard_job = OnboardJob.new
    @onboard_job.store_dependencies(foreman_resource: @mock_foreman_resource,
                                    request: @mock_request)
  end

  test "store_dependencies stores injected dependencies" do
    assert_equal @onboard_job.instance_variable_get(:@foreman_resource), @mock_foreman_resource, "Foreman resource dependency not stored"
    assert_equal @onboard_job.instance_variable_get(:@request), @mock_request, "Request dependency not stored"
  end

  test "store_dependencies defaults to system-wide ForemanApi" do
    onboard_job = OnboardJob.new
    onboard_job.store_dependencies(request: @mock_request)
    assert_equal Dcim::ForemanApiFactory.instance, onboard_job.instance_variable_get(:@foreman_resource), "Foreman resource dependency not obtained from ForemanApiFactory"
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

  test "look up serial provides expected results" do
    input = "USE447ER2L"
    response = {"results"=>{"ops-am2ops-gluster0001"=>{"serialnumber"=>input}}}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_equal @onboard_job.look_up_serial(input), response["results"], "Response does not match expected"
  end

  test "look up serial raises unsupported API response error if results not a Hash" do
    input = "USE447ER2L"
    response = {"results"=>"this should not be a string!"}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_raises(Dcim::UnsupportedApiResponseError) { @onboard_job.look_up_serial(input) }
  end

  test "look up serial raises unsupported API response error with invalid API response" do
    input = "USE447ER2L"
    response = {"error"=>"this is totally unexpected"}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_raises(Dcim::UnsupportedApiResponseError) { @onboard_job.look_up_serial(input) }
  end

  test "look up serial raises duplicate serial error with more than one result" do
    input = "USE447ER2L"
    response = {"results"=>{"ops-am2ops-gluster0001"=>{"serialnumber"=>input},"ops-am2ops-gluster0002"=>{"serialnumber"=>input}}}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_raises(Dcim::DuplicateSerialError) { @onboard_job.look_up_serial(input) }
  end

  test "check serial onboarded in Foreman if Foreman host is promoted" do
    input = "USE447ER2L"
    response = {"results"=>{"ops-am2ops-gluster0001"=>{"serialnumber"=>input}}}
    @onboard_job.expects(:look_up_serial).with(input).returns(response)
    assert @onboard_job.serial_onboarded?(input), "Serial reported not found in Foreman when it should be"
  end

  test "check serial onboarded in Foreman if Foreman host is not promoted" do
    input = "USE447ER2L"
    response = {"results"=>{""=>{"serialnumber"=>input}}}
    @onboard_job.expects(:look_up_serial).with(input).returns(response)
    assert @onboard_job.serial_onboarded?(input), "Serial reported not found in Foreman when it should be"
  end

  test "check serial not onboarded in Foreman" do
    input = "USE447ER2L"
    response = {}
    @onboard_job.expects(:look_up_serial).with(input).returns(response)
    assert_not @onboard_job.serial_onboarded?(input), "Serial reported found in Foreman when it should not be"
  end

  test "serial to system name" do
    serial = "USE447ER2L"
    name = "ops-am2ops-gluster0001"
    response = {name=>{"serialnumber"=>serial}}
    @onboard_job.expects(:look_up_serial).with(serial).returns(response)
    assert_equal @onboard_job.serial_to_system_name(serial), name, "Correct name not returned"
  end

  test "serial to system name returns false if Foreman host is not promoted" do
    input = "USE447ER2L"
    response = {"results"=>{""=>{"serialnumber"=>input}}}
    Dcim::ApiQuery.any_instance.expects(:get).returns(Dcim::ApiResult.new(nil))
    Dcim::ApiResult.any_instance.expects(:to_hash).returns(response)
    assert_not @onboard_job.serial_to_system_name(input), "System name returned when there shouldn't be one"
  end

  test "serial to system name returns false if serial not onboarded in Foreman" do
    input = "USE447ER2L"
    response = {}
    @onboard_job.expects(:look_up_serial).with(input).returns(response)
    assert_not @onboard_job.serial_to_system_name(input), "System name returned when there shouldn't be one"
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

  test "initialize job" do
    @mock_request.status = 2
    @mock_request.error_message = "this should disappear"
    @mock_request.save!
    @onboard_job.set_in_progress
    assert_equal "in_progress", @mock_request.status, "Status should be in progress"
    assert_nil @mock_request.error_message, "Error message should be undefined"
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

  test "finish job" do
    @onboard_job.finish!
    assert_equal @mock_request.status, "complete", "Status isn't success"
  end

  test "prepare all BmcHosts in OnboardRequest for onboarding" do
    @mock_request.bmc_hosts.each do |bmc_host|
      bmc_host.onboard_status = :stack_trace
      bmc_host.onboard_step = :complete
      bmc_host.onboard_error_message = "Fake news!"
      bmc_host.save!
    end
    BmcHost.any_instance.expects(:validate_onboardable).at_least_once.returns true
    @onboard_job.set_bmc_hosts_ready_to_onboard
    @mock_request.bmc_hosts.each do |bmc_host|
      assert_equal "in_progress", bmc_host.onboard_status, "Onboard status should be in progress"
      assert_nil bmc_host.onboard_step, "Onboard step should be nil"
      assert_nil bmc_host.onboard_error_message, "Onboard error message should be nil"
    end
  end

  test "BmcHosts fail onboardable check when preparing for onboarding" do
    @mock_request.bmc_hosts.each do |bmc_host|
      bmc_host.onboard_status = :in_progress
      bmc_host.onboard_step = :complete
      bmc_host.onboard_error_message = "Fake news!"
      bmc_host.save!
    end
    BmcHost.any_instance.expects(:validate_onboardable).at_least_once.raises Dcim::BmcHostIncompleteError
    @onboard_job.set_bmc_hosts_ready_to_onboard
    @mock_request.bmc_hosts.each do |bmc_host|
      assert_equal "stack_trace", bmc_host.onboard_status, "Onboard status should show stack trace"
      assert_nil bmc_host.onboard_step, "Onboard step should remain nil"
      assert bmc_host.onboard_error_message.include?("Dcim::BmcHostIncompleteError"), "Onboard error message should contain exception"
    end
  end

  test "set BmcHosts ready to onboard returns only onboardable BmcHosts" do
    @mock_request.stubs(:bmc_hosts).returns Array.new(7) { bmc_hosts(:one).clone }
    BmcHost.any_instance.expects(:validate_onboardable).times(7).returns(true, false, true, true, false, false, true)
    result = @onboard_job.set_bmc_hosts_ready_to_onboard
    assert result.is_a?(Array), "Expected return of Array"
    assert_equal 4, result.length, "Array length mismatch"
    result.each do |item|
      assert item.is_a?(BmcHost), "Item in array should be a BmcHost"
    end
  end

  test "perform job runs all the expected methods" do
    @onboard_job.expects(:store_dependencies)
    @onboard_job.expects(:set_in_progress)
    BmcHost.any_instance.expects(:validate_onboardable).at_least_once.returns true
    @onboard_job.expects(:onboard).at_least_once
    @onboard_job.expects(:finish!)
    @onboard_job.expects(:fail_with_error).never
    assert @onboard_job.perform
  end

  test "error handling failure in individual onboard" do
    @onboard_job.expects(:store_dependencies)
    @onboard_job.expects(:onboard).at_least_once.raises Dcim::UnknownError
    BmcHost.any_instance.expects(:validate_onboardable).at_least_once.returns true
    @onboard_job.expects(:fail_with_error).with() { |e| e.message.include? "Dcim::UnknownError" }
    @onboard_job.perform
  end

  test "associate BmcHost with new System" do
    bmc_host = @mock_request.bmc_hosts.first
    system = systems(:one)
    foreman_host_id = system.foreman_host_id
    System.expects(:find_by).with(foreman_host_id: foreman_host_id).returns(nil)
    System.expects(:new).with(foreman_host_id: foreman_host_id).returns(system)
    assert @onboard_job.associate_bmc_host_with_system(bmc_host, foreman_host_id), "method did not return true"
    assert_equal bmc_host.system, system, "BmcHost not associated with System"
  end

  test "associate BmcHost to existing System" do
    bmc_host = @mock_request.bmc_hosts.first
    system = systems(:one)
    foreman_host_id = system.foreman_host_id
    System.expects(:find_by).with(foreman_host_id: foreman_host_id).returns(system)
    System.expects(:new).never
    assert @onboard_job.associate_bmc_host_with_system(bmc_host, foreman_host_id), "method did not return true"
    assert_equal bmc_host.system, system, "BmcHost not associated with System"
  end

  test "add BmcHost credentials to Foreman NIC" do
    bmc_host = @mock_request.bmc_hosts.first
    foreman_host_id = 1337
    interface =
      {"managed"=>false,
       "identifier"=>"ipmi",
       "id"=>3514,
       "name"=>nil,
       "ip"=>"10.246.0.69",
       "ip6"=>nil,
       "mac"=>"40:f2:e9:af:ab:8d",
       "primary"=>false,
       "provision"=>false,
       "type"=>"bmc",
       "username"=>nil,
       "password"=>nil,
       "provider"=>"IPMI",
       "virtual"=>false}
    interfaces =
      {"total"=>2,
       "results"=>
        [{"managed"=>true,
          "identifier"=>"ens4f0",
          "id"=>3493,
          "ip"=>"10.246.62.15",
          "ip6"=>nil,
          "mac"=>"a0:36:9f:4d:34:38",
          "primary"=>true,
          "provision"=>true,
          "type"=>"interface",
          "virtual"=>false},
          interface]}
    payload =
      {'username': bmc_host.username,
       'password': bmc_host.password,
       'type': 'bmc'}
    Dcim::ApiQuery.any_instance.expects(:get).returns(interfaces)
    Dcim::ApiQuery.any_instance.expects(:put).with(payload.to_json).returns(interface.merge(payload))
    assert @onboard_job.add_bmc_host_credentials_to_foreman_host(bmc_host, foreman_host_id), "method did not return true"
  end

  test "add BmcHost credentials to Foreman NIC raises missing record error if Foreman NIC does not have type bmc" do
    bmc_host = @mock_request.bmc_hosts.first
    foreman_host_id = 1337
    interfaces = {"total"=>0,"results"=>[]}
    Dcim::ApiQuery.any_instance.expects(:get).returns(interfaces)
    assert_raises(Dcim::MissingRecordError) do
      @onboard_job.add_bmc_host_credentials_to_foreman_host(bmc_host, foreman_host_id)
    end
  end

  test "add BmcHost credentials to Foreman NIC raises unsupported API response error if results is not an array" do
    bmc_host = @mock_request.bmc_hosts.first
    foreman_host_id = 1337
    interfaces = {"total"=>0,"results"=>"this should not be a string!"}
    Dcim::ApiQuery.any_instance.expects(:get).returns(interfaces)
    assert_raises(Dcim::UnsupportedApiResponseError) do
      @onboard_job.add_bmc_host_credentials_to_foreman_host(bmc_host, foreman_host_id)
    end
  end

  test "add BmcHost credentials to Foreman NIC raises unsupported API response error if invalid API response" do
    bmc_host = @mock_request.bmc_hosts.first
    foreman_host_id = 1337
    interfaces = {"total"=>0,"result"=>[]}
    Dcim::ApiQuery.any_instance.expects(:get).returns(interfaces)
    assert_raises(Dcim::UnsupportedApiResponseError) do
      @onboard_job.add_bmc_host_credentials_to_foreman_host(bmc_host, foreman_host_id)
    end
  end

  test "onboard already onboarded" do
    bmc_host = @mock_request.bmc_hosts.first
    @onboard_job.expects(:serial_onboarded?).with(bmc_host.serial).returns(true)
    BmcHost.any_instance.expects(:update).with(onboard_step: :shutdown).never
    BmcHost.any_instance.expects(:update).with(onboard_step: :manage)
    @onboard_job.expects(:serial_to_system_name).with(bmc_host.serial).returns('noop')
    @onboard_job.expects(:system_name_to_system_id).with('noop').returns(1337)
    @onboard_job.expects(:associate_bmc_host_with_system)
    BmcHost.any_instance.expects(:update).with(onboard_step: :bmc_creds)
    @onboard_job.expects(:add_bmc_host_credentials_to_foreman_host).returns(true)
    assert @onboard_job.onboard(bmc_host), "Onboard did not return true"
    assert_equal "success", bmc_host.onboard_status, "BmcHost onboard status should be success"
    assert_equal "complete", bmc_host.onboard_step, "BmcHost onboard step should be complete"
    assert_nil bmc_host.onboard_error_message, "There should be no BmcHost error message"
  end

  test "onboard not already onboarded" do
    bmc_host = @mock_request.bmc_hosts.first
    @onboard_job.expects(:serial_onboarded?).with(bmc_host.serial).returns(false)
    [:shutdown, :power_off, :pxe, :discover, :manage, :bmc_creds].each do |step|
      BmcHost.any_instance.expects(:update).with(onboard_step: step)
    end
    @onboard_job.expects(:keep_trying).times(5)
    @onboard_job.expects(:associate_bmc_host_with_system)
    @onboard_job.expects(:add_bmc_host_credentials_to_foreman_host).returns(true)
    assert @onboard_job.onboard(bmc_host), "Onboard did not return true"
  end

  test "onboard timeout" do
    bmc_host = @mock_request.bmc_hosts.first
    @onboard_job.expects(:serial_onboarded?).with(bmc_host.serial).returns(false)
    @onboard_job.expects(:keep_trying).at_least_once.raises Timeout::Error
    @onboard_job.onboard(bmc_host)
    assert_equal "stack_trace", bmc_host.onboard_status, "BmcHost onboard status should be stack trace"
    assert bmc_host.onboard_error_message.try(:include?, "Dcim::JobTimeoutError"), "BmcHost onboard error message should contain name of exception"
  end

  test "onboard timeout during step manage" do
    bmc_host = @mock_request.bmc_hosts.first
    @onboard_job.expects(:serial_onboarded?).with(bmc_host.serial).returns(true)
    @onboard_job.expects(:keep_trying).at_least_once.raises Timeout::Error
    @onboard_job.onboard(bmc_host)
    assert_equal "stack_trace", bmc_host.onboard_status, "BmcHost onboard status should be stack trace"
    assert bmc_host.onboard_error_message.try(:include?, "Dcim::JobTimeoutError"), "BmcHost onboard error message should contain name of exception"
  end

  test "onboard try shutdown" do
    bmc_host = @mock_request.bmc_hosts.first
    BmcHost.any_instance.expects(:shutdown)
    BmcHost.any_instance.expects(:power_on?).returns(false)
    assert_equal false, @onboard_job.try_shutdown(bmc_host), "Try shutdown did not return false"
  end

  test "onboard try power off" do
    bmc_host = @mock_request.bmc_hosts.first
    BmcHost.any_instance.expects(:power_off)
    BmcHost.any_instance.expects(:power_on?).returns(false)
    assert_equal false, @onboard_job.try_power_off(bmc_host), "Try power off did not return false"
  end

  test "onboard try pxe" do
    bmc_host = @mock_request.bmc_hosts.first
    BmcHost.any_instance.expects(:power_on_pxe)
    BmcHost.any_instance.expects(:power_on?).returns(true)
    assert_equal true, @onboard_job.try_pxe(bmc_host), "Try power on PXE did not return true"
  end

  test "onboard try discover" do
    bmc_host = @mock_request.bmc_hosts.first
    @onboard_job.expects(:serial_onboarded?).with(bmc_host.serial).returns(true)
    assert_equal true, @onboard_job.try_discover(bmc_host), "Try discover did not return true"
  end
end
