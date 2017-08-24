class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def initialize
    @foreman_resource = Dcim::ForemanApiFactory.instance
    @logger = Dcim::ExceptionCollector.new
    super
  end

  def datatable
    respond_to do |format|
      format.json { render json: params[:klass].new(view_context, params) }
    end
  end
end
