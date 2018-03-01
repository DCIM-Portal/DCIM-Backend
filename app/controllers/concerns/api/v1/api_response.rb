module Api::V1::ApiResponse
  extend ActiveSupport::Concern

  included do
    around_action :api_response
  end

  class_methods do
    def status_symbol_from_exception(exception)
      case exception
        when ActiveRecord::RecordNotFound
          :not_found
        else
          :bad_request
      end
    end
  end

  def default_render(*args); end

  protected

  def api_response
    @metadata ||= {}
    data = yield
    @data ||= data
  rescue StandardError => e
    @metadata[:status] = self.class.status_symbol_from_exception(e)
    @metadata[:error] ||= {}
    @metadata[:error][:class] = e.class.name
    @metadata[:error][:message] = e.message
    @metadata[:error][:backtrace] = e.backtrace
  ensure
    return false if performed?
    render status: @metadata.delete(:status) || :ok,
           json: build_api_response(@data, **@metadata)
  end

  def build_api_response(data, **metadata)
    hash = {}
    hash[:data] = build_api_response_data(data, **metadata)
    hash[:class] = data.class.name
    hash[:iterable] = data.respond_to?(:each)
    hash.merge!(@metadata)
    hash
  end

  def build_api_response_data(data, **metadata)
    if data.respond_to?(:each)
      data.map do |datum|
        build_api_response_data(datum, **metadata)
      end
    elsif data.is_a?(ApplicationRecord)
      data.serializable_hash.symbolize_keys.except(*forbidden_read_columns)
    else
      data
    end
  end
end