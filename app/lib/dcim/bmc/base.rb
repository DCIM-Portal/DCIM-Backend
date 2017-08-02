module Dcim::Bmc
  class Base
    def initialize(**kwargs)
      @resource = kwargs[:resource]
    end

    # BmcScanJob methods
    def fru_list
      raise NotImplementedError
    end

    def model(fru_list=nil)
      raise NotImplementedError
    end

    def model(fru_list=nil)
      raise NotImplementedError
    end

    # OnboardJob methods
    def power_on?
      raise NotImplementedError
    end

    def shutdown
      raise NotImplementedError
    end
    
    def power_off
      raise NotImplementedError
    end

    def power_on_pxe
      raise NotImplementedError
    end
  end
end
