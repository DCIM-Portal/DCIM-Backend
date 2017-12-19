module Dcim::Logger
  def logger(provided_logger = nil)
    @logger ||= provided_logger || Rails.logger
  end
end
