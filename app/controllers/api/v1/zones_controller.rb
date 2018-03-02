class Api::V1::ZonesController < Api::V1::ApiController
  resource_description do
    short 'Analogous to Foreman locations, zones contain enclosure racks and/or child zones'
  end

  api! 'List zones'
  def index
    super
  end

  api! 'Show a zone'
  def show
    super
  end

  api! 'Create a zone'
  def create
    super
  end

  api! 'Edit a zone'
  def update
    super
  end

  api! 'Delete a zone'
  def destroy
    super
  end

  include Api::V1::ZonesControllerDiff
end
