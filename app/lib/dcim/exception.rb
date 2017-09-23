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

  class BmcBusyError < BmcHostError
  end

  class SdrCacheError < BmcHostError
  end

  class UnsupportedFruError < BmcHostError
  end

  class BmcHostIncompleteError < BmcHostError
  end

  # Dcim timeout errors
  class TimeoutError < Dcim::Error
  end

  class ConnectionTimeoutError < TimeoutError
  end

  class SessionTimeoutError < TimeoutError
  end

  class JobTimeoutError < TimeoutError
  end

  class CooldownError < TimeoutError
    attr_accessor :max, :elapsed

    def initialize(msg = nil)
      if msg.is_a? Hash
        @max = msg[:max]
        @elapsed = msg[:elapsed]
        @instantiated_at = Time.now
      end
      super
    end

    def expiry
      @instantiated_at + (@max - @elapsed)
    end

    def message
      I18n.t(:cooldown_message_html, max: @max, elapsed: @elapsed, expiry: expiry.iso8601, default: "ends at #{expiry}")
    end
  end

  class JobCooldownError < CooldownError
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
