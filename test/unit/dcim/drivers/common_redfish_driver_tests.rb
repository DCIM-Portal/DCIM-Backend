require 'test_helper'

module Dcim
  module Drivers
    module CommonRedfishDriverTests
      extend ActiveSupport::Concern

      included do
        test 'generate component tree' do
          driver = RedfishDriver.new(@agent)
          driver.collect_facts

          assert_not_empty(@agent.components.where(type: 'ChassisComponent'))
          assert_not_empty(@agent.components.where(type: 'BoardComponent'))
          assert_not_empty(@agent.components.where(type: 'CpuComponent'))
          assert_not_empty(@agent.components.where(type: 'RamComponent'))

          assert(@agent.components.find_by(type: 'BoardComponent').parent.is_a?(ChassisComponent))
          @agent.components.where(type: 'CpuComponent').each do |cpu_component|
            assert(cpu_component.parent.is_a?(BoardComponent))
          end
          @agent.components.where(type: 'RamComponent').each do |ram_component|
            assert(ram_component.parent.is_a?(BoardComponent))
          end
        end
      end
    end
  end
end
