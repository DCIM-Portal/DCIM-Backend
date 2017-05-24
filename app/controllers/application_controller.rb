class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

def initialize
   @foreman_resource = Dcim::ForemanApiFactory.instance
   super
end

end
