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

  def structure
    @data = []
    foreign_keys_info = model_class
                        .reflect_on_all_associations(:belongs_to)
                        .map { |association| [association.foreign_key, association] }
                        .to_h
    columns_hash = model_class.columns_hash
    columns_hash.each do |column_name, adapter|
      column_info = {}
      column_info[:name] = column_name
      column_info[:type] = adapter.type
      column_info[:limit] = adapter.limit

      # Handle primary key
      if model_class.primary_key == column_name
        column_info[:type] = :primary_key
      # Handle enums
      elsif model_class.defined_enums.key?(column_name)
        column_info[:type] = :enum
        column_info[:enum] = model_class.defined_enums[column_name]
      # Handle foreign keys
      elsif foreign_keys_info.key?(column_name)
        column_info[:type] = :foreign_key
        foreign_key = foreign_keys_info[column_name]
        column_info[:foreign_key] = {
          name: foreign_key.name,
          plural_name: foreign_key.plural_name
        }
      end

      column_info[:readable?] = !forbidden_read_columns.include?(column_name.to_sym)
      column_info[:writable?] = !forbidden_write_columns.include?(column_name.to_sym)
      column_info[:accessible?] = !forbidden_access_columns.include?(column_name.to_sym)

      @data << column_info
    end
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
