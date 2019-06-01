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
      end

      include Dcim::Drivers::CommonRedfishDriverTests

      test 'System Memory SizeMB normalized correctly' do
        driver = RedfishDriver.new(@agent)
        driver.collect_facts

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
    end
  end
end
