require 'test_helper'
require_relative 'common_redfish_driver_tests'

module Dcim
  module Drivers
    class IloRedfishDriverTest < ActiveSupport::TestCase
      def setup
        @agent = agents(:ilo4_agent)
        @host = agent_properties(:ilo4_agent_property_host).value
        uri_match = Regexp.new(Regexp.quote(@host) + '/.*$')
        stub_request(:get, uri_match)
          .to_return(body: lambda { |request|
                             redfish_path = request.uri.path.split('/')
                             File.new(Rails.root.join('test', 'helpers', 'redfish-ilo4', *redfish_path, 'index.json'))
                           })
        @driver = RedfishDriver.new(@agent)
      end

      include Dcim::Drivers::CommonRedfishDriverTests

      test 'System Memory SizeMB normalized correctly' do
        @driver.collect_facts

        memory_component = @agent.components
                                 .joins(:properties)
                                 .find_by(
                                   type: RamComponent.name,
                                   component_properties: {
                                     key: 'name',
                                     value: 'proc1dimm1'
                                   }
                                 )

        assert_equal(32_768_000_000, memory_component
                                         .properties
                                         .find_by(key: 'capacity')
                                         .value.to_i)
      end

      test 'collect node parent is component that it fetches' do
        out = @driver.collect('Chassis', '/redfish/v1/Chassis/1/', nil)
        assert(out[:parent].is_a?(ChassisComponent))
      end

      test 'collect node passes through parent if node has no component' do
        parent = Component.new
        out = @driver.collect('MemoryCollection', '/redfish/v1/Systems/1/Memory/', parent)
        assert_equal(parent, out[:parent])
      end

      test 'collect node next has link API paths' do
        out = @driver.collect('System', '/redfish/v1/Systems/1/', nil)
        actual_next = out[:next]
        assert_includes(actual_next['ProcessorCollection'], '/redfish/v1/Systems/1/Processors/')
        assert_includes(actual_next['MemoryCollection'], '/redfish/v1/Systems/1/Memory/')
      end

      test 'collect node next has members API paths' do
        out = @driver.collect('Chassis', '/redfish/v1/Chassis/1/', nil)
        actual_next = out[:next]
        assert_includes(actual_next['System'], '/redfish/v1/Systems/1/')
      end
    end
  end
end
