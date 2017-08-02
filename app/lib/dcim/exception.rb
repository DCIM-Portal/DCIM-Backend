module Dcim

  class Error < RuntimeError
  end

  class BmcScanError < Dcim::Error
  end

  class InvalidCredentialsError < Dcim::Error
  end

  class InvalidUsernameError < InvalidCredentialsError
  end

  class InvalidPasswordError < InvalidCredentialsError
  end

  class TimeoutError < Dcim::Error
  end

  class ConnectionTimeoutError < TimeoutError
  end

  class SessionTimeoutError < TimeoutError
  end

  class JobTimeoutError < TimeoutError
  end

  class BmcBusyError < Dcim::Error
  end

  class SdrCacheError < Dcim::Error
  end

  class UnsupportedFruError < Dcim::Error
  end

  class UnknownError < Dcim::Error
  end

  class UnsupportedApiResponseError < Dcim::Error
  end

  class DuplicateRecordError < Dcim::Error
  end

  class DuplicateSerialError < DuplicateRecordError
  end

  class DuplicateIpError < DuplicateRecordError
  end

  class SmartProxyError < Dcim::Error
  end

  class InvalidSmartProxyError < SmartProxyError
  end

end

