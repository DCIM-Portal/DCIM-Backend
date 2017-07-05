module Dcim

  class ExceptionCollector

     WARNING = "warning"
     ERROR = "danger"
     INFO = "info"

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
     
