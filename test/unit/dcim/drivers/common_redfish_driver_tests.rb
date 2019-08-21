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

        test 'capabilities module is the correct module' do
          driver = RedfishDriver.new(@agent)
          assert_equal(Dcim::Drivers::Capabilities::RedfishDriver, driver.capabilities_module)
        end

        test 'supported components provides set of supported component classes' do
          driver = RedfishDriver.new(@agent)
          components = driver.supported_components
          assert_includes(components, BoardComponent)
        end

        test 'supported commands provides set of component command symbols' do
          driver = RedfishDriver.new(@agent)
          commands = driver.supported_commands(BoardComponent)
          assert_includes(commands, :power_off)
        end
      end
    end
  end
end
