require 'test_helper'

class SystemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @system = systems(:one)
  end

  test "should get index" do
    get systems_url
    assert_response :success
  end

  test "should get new" do
    get new_system_url
    assert_response :success
  end

  test "should create system" do
    assert_difference('System.count') do
      post systems_url, params: { system: { cpu_cores: @system.cpu_cores, cpu_count: @system.cpu_count, cpu_model: @system.cpu_model, cpu_threads: @system.cpu_threads, disk_count: @system.disk_count, disk_total: @system.disk_total, name: @system.name, os: @system.os, os_release: @system.os_release, ram_total: @system.ram_total, sync_status: @system.sync_status } }
    end

    assert_redirected_to system_url(System.last)
  end

  test "should show system" do
    get system_url(@system)
    assert_response :success
  end

  test "should get edit" do
    get edit_system_url(@system)
    assert_response :success
  end

#  test "should update system" do
#    patch system_url(@system), params: { system: { cpu_cores: @system.cpu_cores, cpu_count: @system.cpu_count, cpu_model: @system.cpu_model, cpu_threads: @system.cpu_threads, disk_count: @system.disk_count, disk_total: @system.disk_total, name: @system.name, os: @system.os, os_release: @system.os_release, ram_total: @system.ram_total, sync_status: @system.sync_status } }
#    assert_redirected_to system_url(@system)
#  end

  test "should destroy system" do
    assert_difference('System.count', -1) do
      delete system_url(@system)
    end

    assert_redirected_to systems_url
  end
end
