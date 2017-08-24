class LiveView
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
  attr_reader :params

  def initialize(params)
    @params = LiveViewParam.new(params)
  end
end

class LiveViewParam
  def initialize(params)
    @params = params || {}
  end

  def [](key)
    LiveViewParam.new(@params[key])
  end

  def to_unsafe_h
    @params
  end

  def method_missing(method, *args)
    return @params.send(method, *args) if @params.respond_to?(method)
    super
  end
end
