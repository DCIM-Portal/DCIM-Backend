class Api::V1::ApiController < ApplicationController
  before_action :authenticate_user
  around_action :api_response

  resource_description do
    api_version '1'
  end

  def index
    @data = model_class.all
  end

  def show
    @data = model_class.find(params[:id])
  end

  def create
    new_model = model_class.new
    apply_params_to_model(params, new_model)
    new_model.save!
    @data = new_model
  end

  def update
    model = model_class.find(params[:id])
    apply_params_to_model(params, model)
    model.save!
    @data = model
  end

  def destroy
    model = model_class.find(params[:id])
    model.destroy!
    @data = model
  end

  def default_render(*args); end

  protected

  def api_response
    @metadata ||= {}
    data = yield
    @data ||= data
  rescue StandardError => e
    Rails.logger.warn e
    @metadata[:error] ||= {}
    @metadata[:error][:class] = e.class.name
    @metadata[:error][:message] = e.message
    @metadata[:error][:backtrace] = e.backtrace
  ensure
    render json: build_api_response(@data, **@metadata) unless performed?
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

  def apply_params_to_model(params, model)
    column_names = model.class.column_names
    params.each do |key, param|
      if column_names.include?(key) &&
         !forbidden_write_columns.include?(key)
        model.send "#{key}=", param
      end
    end
  end

  def model_class
    @model_class ||= self.class.name.demodulize.sub(/Controller$/, '').singularize.constantize
  end

  def forbidden_access_columns
    @forbidden_access_columns ||= %i[]
  end

  def forbidden_write_columns
    forbidden_access_columns + (@forbidden_write_columns ||= %i[id created_at updated_at])
  end

  def forbidden_read_columns
    forbidden_access_columns + (@forbidden_read_columns ||= %i[])
  end
end
