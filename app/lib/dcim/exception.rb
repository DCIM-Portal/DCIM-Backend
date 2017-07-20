module Dcim

  class BmcScanError < RuntimeError
  end

  class InvalidCredentialsError < RuntimeError
  end

  class InvalidUsernameError < InvalidCredentialsError
  end

  class InvalidPasswordError < InvalidCredentialsError
  end

  class ConnectionTimeoutError < RuntimeError
  end

  class UnsupportedFruError < RuntimeError
  end

  class UnknownError < RuntimeError
  end

end

