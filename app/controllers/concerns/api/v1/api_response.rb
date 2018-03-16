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
      when RestClient::InternalServerError
        :internal_server_error
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
    @data = data if @data.is_a?(Hash) && @data.empty?
  rescue StandardError => e
    @metadata[:status] = self.class.status_symbol_from_exception(e)
    @metadata[:error] ||= {}
    @metadata[:error][:class] = e.class.name
    @metadata[:error][:message] = e.message
    @metadata[:error][:backtrace] = e.backtrace
  ensure
    unless performed?
      render status: @metadata.delete(:status) || :ok,
             json: build_api_response(@data, **@metadata)
    end
  end

  def build_api_response(data, **metadata)
    hash = {}
    hash[:data] = build_api_response_data(data, **metadata)
    debug_meta = {
        params: params,
        class: data.class.name,
        iterable: data.respond_to?(:to_ary)
    }
    hash[:debug] = debug_meta
    hash.merge!(@metadata)
    hash
  end

  def build_api_response_data(data, **metadata)
    if data.is_a?(ApplicationRecord)
      data.serializable_hash.symbolize_keys.except(*forbidden_read_columns)
    elsif data.respond_to?(:to_ary)
      data.map do |datum|
        build_api_response_data(datum, **metadata)
      end
    else
      data
    end
  end
end
