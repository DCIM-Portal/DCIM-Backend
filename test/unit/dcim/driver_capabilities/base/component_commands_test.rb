require 'test_helper'

module Dcim
  module DriverCapabilities
    module Base
      class NoopComponentCommands < ComponentCommands
        preference 1
        def noop1; end

        preference 5
        def noop5; end
      end

      class ComponentCommandsTest < ActiveSupport::TestCase
        test 'ComponentCommand preference is stored in class' do
          assert_equal(1, NoopComponentCommands.preference_of(:noop1))
          assert_equal(5, NoopComponentCommands.preference_of(:noop5))
        end
      end
    end
  end
end
