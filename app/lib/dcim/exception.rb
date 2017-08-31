module Dcim

# All DCIM errors
  class Error < RuntimeError
  end

# BMC scan errors
  class BmcScanError < Dcim::Error
  end

# BMC host errors
  class BmcHostError < Dcim::Error
  end

  class InvalidCredentialsError < BmcHostError
  end

  class InvalidUsernameError < InvalidCredentialsError
  end

  class InvalidPasswordError < InvalidCredentialsError
  end

  class TimeoutError < BmcHostError
  end

  class ConnectionTimeoutError < TimeoutError
  end

  class SessionTimeoutError < TimeoutError
  end

  class JobTimeoutError < TimeoutError
  end

  class BmcBusyError < BmcHostError
  end

  class SdrCacheError < BmcHostError
  end

  class UnsupportedFruError < BmcHostError
  end

  class BmcHostIncompleteError < BmcHostError
  end

# Unknown errors
  class UnknownError < Dcim::Error
  end

# API errors
  class UnsupportedApiResponseError < Dcim::Error
  end

  class RecordError < Dcim::Error
  end

  class MissingRecordError < RecordError
  end

  class DuplicateRecordError < RecordError
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

