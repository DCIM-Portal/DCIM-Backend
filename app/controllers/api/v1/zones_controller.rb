class Api::V1::ZonesController < Api::V1::ApiController
  resource_description do
    short 'Analogous to Foreman locations, Zones contain EnclosureRacks and/or child Zones'
  end
  api! 'List Zones'
  def index
    super
  end

  api! 'Show a Zone'
  def show
    super
  end

  api! 'Create a Zone'
  def create
    super
  end

  api! 'Edit a Zone'
  def update
    super
  end

  api! 'Delete a Zone'
  def destroy
    super
  end
end
