class AdminController < ApplicationController
  include Admin::Filters
  layout 'admin_page'

  add_breadcrumb 'Admin', :admin_path

  # TODO: Authenticate admin user

  def index
    respond_to do |format|
      format.html
    end
  end
end
