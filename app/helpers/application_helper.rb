module ApplicationHelper
  def active?(controller)
    'active-item' if params[:controller] == controller
  end

  def parent_menu(controller)
    'unfold' if params[:controller] == controller
  end
end
