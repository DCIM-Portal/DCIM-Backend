module Dcim
  module Drivers
    module Capabilities
      module Base
        class BoardComponentCommands < ComponentCommands
          # Graceful shutdown
          def shut_down
            raise NotImplementedError
          end

          # Forceful power off
          def power_off
            raise NotImplementedError
          end

          # Power on
          def power_on
            raise NotImplementedError
          end

          # Immediately reboot
          # @param mode [Symbol] How to reboot
          #   :cold Removes and then restores power
          #   :warm Reset the board without removing power
          def power_reset(mode: :warm)
            raise NotImplementedError
          end

          # Set the boot source for the next reboot only
          # @param boot_source [Symbol] Boot source
          #   :default Unset the boot source override
          #   :pxe PXE boot
          #   :floppy Floppy disk
          #   :cd Compact Disc
          #   :usb USB Mass Storage Device
          #   :hdd Hard disk drive
          #   :utilities Vendor utilities
          #   :bios_setup Firmware settings
          def next_boot_source=(boot_source)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
