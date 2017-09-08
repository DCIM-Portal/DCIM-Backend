class AdminController < ApplicationController
  # TODO: Authenticate admin user

  def index
    respond_to do |format|
      format.html
    end
  end
end
