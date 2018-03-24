class Api::V1::ApiController < ApplicationController
  include ApiResponse
  include AutoApiDocs

  before_action :authenticate_user
  before_action :initialize_foreman_resource

  resource_description do
    api_version '1'
  end

  def initialize_foreman_resource
    # XXX: No CSRF token support when Foreman is authenticating in session mode
    #      Using default admin-authenticated resource until we find a better solution
    # @foreman_resource = current_user.foreman_api
  end

  def index
    search = Dcim::Search::ApplicationSearch.search(model_class, params, forbidden_read_columns)

    pagination_info = search.pagination_info
    @metadata[:pagination] = pagination_info unless pagination_info.empty?

    search_info = search.search_info
    @metadata[:search] = search_info unless search_info.empty?

    filters_info = search.filters_info
    @metadata[:filters] = filters_info unless filters_info.empty?

    order_info = search.order_info
    @metadata[:order] = order_info unless order_info.empty?

    @data = search.results
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
