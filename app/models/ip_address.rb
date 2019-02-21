class IpAddress
  class Type < ActiveRecord::Type::Value
    def cast(value)
      return value if value =~ Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex)

      IPAddr.new(value.to_i, Socket::AF_INET6).native.to_s
    end

    def serialize(value)
      IPAddr.new(value).to_i
    end
  end
end
