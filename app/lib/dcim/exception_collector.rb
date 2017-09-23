module Dcim
  class ExceptionCollector
    WARNING = 'orange lighten-2'.freeze
    ERROR = 'red lighten-2'.freeze
    INFO = 'info-color'.freeze

    def initialize
      @exceptions = []
    end

    def log(**kwargs)
      @exceptions << kwargs
    end

    def warn(**kwargs)
      log(type: WARNING, **kwargs)
    end

    def error(**kwargs)
      log(type: ERROR, **kwargs)
    end

    def info(**kwargs)
      log(type: INFO, **kwargs)
    end

    def next_item
      @exceptions.each do |x|
        return x[:exception].to_s
      end
    end

    def all
      @exceptions
    end

    def error?
      !@exceptions.empty?
    end
  end
end
