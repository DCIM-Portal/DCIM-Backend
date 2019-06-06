module Dcim
  class CaseInsensitiveHash < HashWithIndifferentAccess
    def [](key)
      super convert_key(key)
    end

    protected

    def convert_key(key)
      key.respond_to?(:downcase) ? key.downcase : key
    end
  end
end