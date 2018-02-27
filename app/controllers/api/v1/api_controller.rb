class Api::V1::ApiController < ApplicationController
  before_action :authenticate_user

  resource_description do
    api_version '1'
  end

  def index
    render json: model.all.as_json
  end

  def create
    column_names = model.column_names
    new_model = model.new

    params.each do |key, param|
      if column_names.include?(key) &&
         !forbidden_write_columns.include?(key)
        new_model.send key, param
      end
    end

    new_model.save!
    render json: new_model.as_json
  end

  def update
    # todo
  end

  def destroy
    # todo
  end

  protected

  def model
    @model ||= self.class.name.demodulize.sub(/Controller$/, '').singularize.constantize
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
