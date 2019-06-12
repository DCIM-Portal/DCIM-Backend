module Dcim
  module DriverCapabilities
    module RedfishDriver
      module BoardComponent
        # Graceful shutdown
        def shut_down
          # TODO
        end

        # Forceful power off
        def power_off
          # TODO
        end

        # Power on
        def power_on
          # TODO
        end

        # Immediately reboot
        # @param mode [Symbol] How to reboot
        #   :cold Removes and then restores power
        #   :warm Reset the board without removing power
        def reboot(mode: :warm)
          # TODO
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
          # TODO
        end
      end
    end
  end
end