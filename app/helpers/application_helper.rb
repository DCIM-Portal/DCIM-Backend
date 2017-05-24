module ApplicationHelper

  def is_active(controller)
    "active" if params[:controller] == controller
  end

end
