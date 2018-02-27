class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  include Knock::Authenticable

  add_breadcrumb 'Home', '/'

  def initialize
    @foreman_resource = Dcim::ForemanApiFactory.instance
    @logger = Dcim::ExceptionCollector.new
    super
  end

  helper_method :datatable
  def datatable(**kwargs)
    if kwargs[:category]
      kwargs[:category_id] = kwargs[:category].id
      kwargs[:category_name] = kwargs[:category].class.name.underscore
    end

    params[:route] = kwargs

    datatable_factory = Dcim::DatatableFactory.new(view_context, params, self.class.name.deconstantize)
    render partial: 'layouts/datatable', locals: { factory: datatable_factory }
  end

  # TODO: Remove: Deprecated
  # def datatable
  #  respond_to do |format|
  #    format.json { render json: params[:klass].new(view_context, params) }
  #  end
  # end
end
