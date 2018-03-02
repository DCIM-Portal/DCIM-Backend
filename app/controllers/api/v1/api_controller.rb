class Api::V1::ApiController < ApplicationController
  include Api::V1::ApiResponse

  before_action :authenticate_user
  before_action :initialize_foreman_resource

  resource_description do
    api_version '1'
  end

  def initialize_foreman_resource
    # XXX: No CSRF token support when Foreman is authenticating in session mode
    #      Using default admin-authenticated resource until we find a better solution
    # @foreman_resource = current_user.foreman_api
    @data ||= {}
    @metadata ||= {}
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
    @forbidden_access_columns ||= %i[]
  end

  def forbidden_write_columns
    forbidden_access_columns + (@forbidden_write_columns ||= %i[id created_at updated_at])
  end

  def forbidden_read_columns
    forbidden_access_columns + (@forbidden_read_columns ||= %i[])
  end
end
