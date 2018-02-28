class Api::V1::ApiController < ApplicationController
  before_action :authenticate_user

  resource_description do
    api_version '1'
  end

  def index
    render json: model_class.all.as_json
  end

  def show
    model = model_class.find(params[:id])
    render json: model.as_json
  end

  def create
    new_model = model_class.new
    apply_params_to_model(params, new_model)
    new_model.save!
    render json: new_model.as_json
  end

  def update
    model = model_class.find(params[:id])
    apply_params_to_model(params, model)
    model.save!
    render json: model.as_json
  end

  def destroy
    model = model_class.find(params[:id])
    model.destroy!
    render json: model.as_json
  end

  protected

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
    @forbidden_access_columns ||= %w[]
  end

  def forbidden_write_columns
    forbidden_access_columns + (@forbidden_write_columns ||= %w[id created_at updated_at])
  end

  def forbidden_read_columns
    forbidden_access_columns + (@forbidden_read_columns ||= %w[])
  end
end
