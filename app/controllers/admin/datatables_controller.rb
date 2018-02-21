class Admin::DatatablesController < AdminController
  def show
    datatable_factory = Dcim::DatatableFactory.new(view_context, params, self.class.name.deconstantize)
    render json: datatable_factory.instance
  end
end
