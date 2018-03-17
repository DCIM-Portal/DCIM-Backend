class Api::V1::HomeController < Api::V1::ApiController
  skip_before_action :authenticate_user

  api! 'Show available resources'
  def index
    # TODO
  end

  api! 'Show information about this app instance'
  def status
    {
      version: Dcim::Version.to_s
    }
  end
end
