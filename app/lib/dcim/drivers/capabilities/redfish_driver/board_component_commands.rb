module Dcim
  module Drivers
    module Capabilities
      module RedfishDriver
        class BoardComponentCommands < Base::BoardComponentCommands
          preference 5

          def shut_down
            # TODO
          end

          preference 5

          def power_off
            # TODO
          end

          preference 5

          def power_on
            # TODO
          end

          preference 5

          def power_reset(mode: :warm)
            # TODO
          end

          preference 5

          def next_boot_source=(boot_source)
            # TODO
          end
        end
      end
    end
  end
end
