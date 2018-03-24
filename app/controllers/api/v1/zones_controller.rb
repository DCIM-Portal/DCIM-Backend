class Api::V1::ZonesController < Api::V1::ApiController
  resource_description do
    short 'Analogous to Foreman locations, zones contain enclosure racks and/or child zones'
  end

  api! 'List zones'
  collection!
  def index
    super
  end

  api! 'Show a zone'
  def show
    super
  end

  api! 'Create a zone'
  params!
  def create
    super
    representation = generate_local_representation(@data)
    response = create_foreman_location(representation)
    @data.foreman_location_id = response['id']
    @data.save!
  end

  api! 'Edit a zone'
  params!
  def update
    super
    representation = generate_local_representation(@data)
    update_foreman_location(representation)
  end

  api! 'Delete a zone'
  def destroy
    super
    representation = generate_local_representation(@data)
    delete_foreman_location(representation)
  end

  include Api::V1::ZonesControllerDiff

  private

  def create_foreman_location(representation)
    @foreman_resource.api.locations.post(
      {
        name: representation[:name],
        parent_id: representation[:parent_id]
      }.to_json
    )
  end

  def update_foreman_location(representation)
    @foreman_resource.api.locations(representation[:foreman_location_id]).put(
      {
        name: representation[:name],
        parent_id: representation[:parent_id]
      }.to_json
    )
  end

  def delete_foreman_location(representation)
    @foreman_resource.api.locations(representation[:foreman_location_id]).delete
  end
end
