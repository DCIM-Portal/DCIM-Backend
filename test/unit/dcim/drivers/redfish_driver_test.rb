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

      test 'something' do
        driver = RedfishDriver.new(@agent)
        driver.collect_facts
      end
    end
  end
end
