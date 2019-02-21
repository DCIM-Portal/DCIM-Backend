module Dcim
  class Version
    include ::Comparable
    class << self
      include ::Comparable
    end
    attr_reader :version, :major, :minor, :patch

    def initialize(override_version = nil)
      @version = override_version || File.read("#{Rails.root}/VERSION").chomp
      @major, @minor, @patch = @version.scan(/\d+/)
    rescue Errno::ENOENT
      @version = 'unknown'
    end

    def to_s
      @version
    end

    def <=>(other)
      Gem::Version.new(@version) <=> Gem::Version.new(other)
    end

    def self.instance
      @instance ||= new
    end

    def self.refresh!
      @instance = nil
      instance
    end

    def self.method_missing(method, *args)
      instance.send method, *args
    end

    def self.<=>(other)
      instance.<=>(other)
    end

    def self.to_s
      instance.to_s
    end
  end
end
