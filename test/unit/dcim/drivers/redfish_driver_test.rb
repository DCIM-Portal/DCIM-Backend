require 'test_helper'

module Dcim
  module Drivers
    class RedfishDriverTest < ActiveSupport::TestCase
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

      test 'generate component tree' do
        driver = RedfishDriver.new(@agent)
        driver.collect_facts

        assert_not_empty(@agent.components.where(type: 'ChassisComponent'))
        assert_not_empty(@agent.components.where(type: 'BoardComponent'))
        assert_not_empty(@agent.components.where(type: 'CpuComponent'))

        assert(@agent.components.find_by(type: 'BoardComponent').parent.is_a?(ChassisComponent))
        @agent.components.where(type: 'CpuComponent').each do |cpu_component|
          cpu_component.parent.is_a?(BoardComponent)
        end
      end
    end
  end
end
