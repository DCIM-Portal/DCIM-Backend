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

  api! 'Find inconsistencies between zones and Foreman locations'
  description <<-DOC
  Zones are one-to-one associations to Foreman locations.
  If zones do not match Foreman locations, data integrity may be compromised.
  A mismatch could occur if the database is modified outside of the control of this controller or if someone makes changes directly in Foreman.

  A zone is considered matched with its Foreman location if the following conditions are true:
  - The +name+ of the zone is the same as the +name+ of its Foreman location.
  - The ID of the zone's parent's Foreman location ID (+parent_id+) is the same as the zone's Foreman location's +parent_id+.

  The data returned by this endpoint contains an Object with the key +differences+.

  If all zones match all Foreman locations, the value of +differences+ will be Boolean +false+.

  Otherwise value of +differences+ is also an Object that contain one or more of the following keys:
  - +only_foreman+ -- Each Object in this Array is a representation of a Foreman location that does not have a matching zone.
  - +only_local+ -- Each Object in this Array is a representation of a zone that does not have a matching Foreman location.
  - +name+ -- Array of matched zones and Foreman locations but mismatched names. See below for the structure of each Array item.
  - +parent_id+ -- Array of matched zones and Foreman locations but mismatched Foreman location parent IDs. See below for the structure of each Array item.

  +differences.name+ and +differences.parent_id+ may contain Arrays of Objects, and those Objects are a pair of matched zones and Foreman locations:
  - +local+ -- Representation of a matching zone
  - +foreman+ -- Representation of a matching Foreman location

  Each representation has these keys:
  - +id+ -- Associated zone ID
  - +foreman_location_id+ -- Associated Foreman location ID
  - +name+ -- Name of the zone or Foreman location, whichever is represented
  - +parent_id+ -- Foreman location parent ID, even if the representation is a zone
  DOC
  see 'zones#diff_resolve', 'how to resolve differences'
  example <<-DOC
  {
      "data": {
          "differences": false
      }
  }
  DOC
  example <<-DOC
  {
      "data": {
          "differences": {
              "only_foreman": [
                  {
                      "id": null,
                      "foreman_location_id": 12,
                      "name": "DELETE-ME",
                      "parent_id": 1
                  }
              ],
              "only_local": [
                  {
                      "id": 6,
                      "foreman_location_id": null,
                      "name": "TEST-ONLY",
                      "parent_id": null
                  },
                  {
                      "id": 7,
                      "foreman_location_id": null,
                      "name": "TEST-ONLY-2",
                      "parent_id": null
                  }
              ],
              "name": [
                  {
                      "local": {
                          "id": 1,
                          "foreman_location_id": 1,
                          "name": "YouEss-East",
                          "parent_id": null
                      },
                      "foreman": {
                          "id": 1,
                          "foreman_location_id": 1,
                          "name": "US-East",
                          "parent_id": null
                      }
                  }
              ],
              "parent_id": [
                  {
                      "local": {
                          "id": 3,
                          "foreman_location_id": 9,
                          "name": "US-West, Segment 1",
                          "parent_id": null
                      },
                      "foreman": {
                          "id": 3,
                          "foreman_location_id": 9,
                          "name": "US-West, Segment 1",
                          "parent_id": 3
                      }
                  }
              ]
          }
      }
  }
  DOC
  def diff
    foreman_locations = @foreman_resource.api.locations.get(payload: { per_page: 1_000_000 }.to_json)['results']
    zones = Zone.all

    diffable_zones = zones.map do |zone|
      generate_local_representation(zone)
    end

    diffable_foreman_locations = foreman_locations.map do |foreman_location|
      {
        id: zones.where(foreman_location_id: foreman_location['id']).first.try(:id),
        foreman_location_id: foreman_location['id'],
        name: foreman_location['name'],
        parent_id: foreman_location['parent_id']
      }
    end

    @data ||= {}
    zone_ids = diffable_zones.map { |h| h[:foreman_location_id] }
    foreman_location_ids = diffable_foreman_locations.map { |h| h[:foreman_location_id] }
    ids_only_in_zones = zone_ids - foreman_location_ids
    ids_only_in_foreman_locations = foreman_location_ids - zone_ids
    matching_ids = (zone_ids & foreman_location_ids) - (ids_only_in_zones & ids_only_in_foreman_locations)

    @data[:differences] ||= {}
    unless (ids_only_in_zones + ids_only_in_foreman_locations).empty?
      @data[:differences][:only_foreman] = diffable_foreman_locations.select { |v| ids_only_in_foreman_locations.include?(v[:foreman_location_id]) }
      @data[:differences][:only_local] = diffable_zones.select { |v| ids_only_in_zones.include?(v[:foreman_location_id]) }
    end

    matching_ids.each do |matching_id|
      zone = diffable_zones.select { |v| v[:foreman_location_id] == matching_id }[0]
      foreman_location = diffable_foreman_locations.select { |v| v[:foreman_location_id] == matching_id }[0]
      if zone[:name] != foreman_location[:name]
        @data[:differences][:name] ||= []
        @data[:differences][:name] << {
          local: zone,
          foreman: foreman_location
        }
      end
      next unless zone[:parent_id] != foreman_location[:parent_id]
      @data[:differences][:parent_id] ||= []
      @data[:differences][:parent_id] << {
        local: zone,
        foreman: foreman_location
      }
    end
    @data[:differences] = false if @data[:differences].empty?
  end

  api! 'Fix inconsistencies between zones and Foreman locations'
  description 'Fix inconsistencies between zones and Foreman locations using the provided strategy or strategies'
  param :strategies, Array, required: true, desc: <<-DOC
  One or more of the following strategies to resolve any inconsistencies:
  [Mismatched +id+]
  - +foreman_add+ -- Create Foreman locations from zones that do not have a matching Foreman location
  - +foreman_remove+ -- Remove Foreman locations that do not have a matching zone
  - +local_add+ -- Create zones from Foreman locations that do not have a matching zone
  - +local_remove+ -- Remove zones that do not have a matching Foreman location
  [Mismatched +name+]
  - +use_foreman_name+ -- Change the zone name to match its Foreman location name if the names differ
  - +use_local_name+ -- Change the Foreman location name to match its zone name if the names differ
  [Mismatched +parent_id+]
  - +use_foreman_parent+ -- Change the zone parent to match its Foreman location parent if the parents differ
  - +use_local_parent+ -- Change the Foreman location parent to match its zone parent if the parents differ
  The strategies will be executed in the order provided and use a one-time generated difference set.
  DOC
  DIFF_RESOLVE_STRATEGIES = %w[
    foreman_add
    foreman_remove
    local_add
    local_remove
    use_foreman_name
    use_local_name
    use_foreman_parent
    use_local_parent
  ].freeze
  def diff_resolve
    requested_strategies = params[:strategies]
    unpermitted_strategies = requested_strategies - DIFF_RESOLVE_STRATEGIES
    raise ActionController::UnpermittedParameters.new(unpermitted_strategies) unless unpermitted_strategies.empty?

    diff
    @data[:changes] = {}
    requested_strategies.each do |strategy|
      more_changes = send("diff_resolve_#{strategy}")
      @data[:changes].merge!(more_changes) if more_changes.is_a?(Hash)
    end
  end

  def diff_resolve_foreman_add
    changes = []
    only_local = @data[:differences].delete(:only_local)
    only_local.each do |representation|
      @foreman_resource.api.locations.post(
          {
              name: representation[:name],
              parent_id: representation[:parent_id]
          }.to_json
      )
      changes << {
          before: nil,
          after: representation
      }
    end
    {foreman: changes}
  end

  def diff_resolve_foreman_remove
    changes = []
    only_foreman = @data[:differences].delete(:only_foreman)
    only_foreman.each do |representation|
      @foreman_resource.api.locations(representation[:foreman_location_id]).delete
    changes << {
          before: representation,
          after: nil
      }
    end
    {foreman: changes}
  end

  def diff_resolve_local_add
    changes = []
    only_foreman = @data[:differences].delete(:only_foreman)
    only_foreman.each do |representation|
      zone = Zone.new(
          name: representation[:name],
          foreman_location_id: representation[:foreman_location_id]
      )
      zone.save!
      changes << {
          before: nil,
          after: representation
      }
    end
    # Figure out parents after all Zones saved
    only_foreman.each do |representation|
      next unless representation[:parent_id]
      zone = Zone.find_by(foreman_location_id: representation[:foreman_location_id])
      zone.parent = Zone.find_by(foreman_location_id: representation[:parent_id])
      zone.save!
    end
    {local: changes}
  end

  def diff_resolve_local_remove
    changes = []
    only_local = @data[:differences].delete(:only_local)
    only_local.each do |representation|
      zone = Zone.find(representation.id)
      zone.destroy!
      changes << {
          before: representation,
          after: nil
      }
    end
    {local: changes}
  end

  def diff_resolve_use_foreman_name
    changes = []
    wrong_names = @data[:differences].delete(:name)
    wrong_names.each do |pair|
      local_representation = pair[:local]
      foreman_representation = pair[:foreman]
      zone = Zone.find(local_representation[:id])
      zone.update(name: foreman_representation[:name])
      changes << {
          before: local_representation,
          after: generate_local_representation(zone)
      }
    end
    {local: changes}
  end

  def diff_resolve_use_local_name
    changes = []
    wrong_names = @data[:differences].delete(:name)
    wrong_names.each do |pair|
      local_representation = pair[:local]
      foreman_representation = pair[:foreman]
      @foreman_resource.api.locations(foreman_representation[:foreman_location_id]).put(
          {
              name: local_representation[:name]
          }.to_json
      )
      new_foreman_representation = foreman_representation
      new_foreman_representation[:name] = local_representation[:name]
      changes << {
          before: foreman_representation,
          after: new_foreman_representation
      }
    end
    {foreman: changes}
  end

  def diff_resolve_use_foreman_parent
    changes = []
    wrong_names = @data[:differences].delete(:name)
    wrong_names.each do |pair|
      local_representation = pair[:local]
      foreman_representation = pair[:foreman]
      zone = Zone.find(local_representation[:id])
      zone.parent = Zone.find_by(foreman_location_id: foreman_representation[:parent_id])
      zone.save!
      changes << {
          before: local_representation,
          after: generate_local_representation(zone)
      }
    end
    {local: changes}
  end

  def diff_resolve_use_local_parent
    changes = []
    wrong_names = @data[:differences].delete(:name)
    wrong_names.each do |pair|
      local_representation = pair[:local]
      foreman_representation = pair[:foreman]
      @foreman_resource.api.locations(foreman_representation[:foreman_location_id]).put(
          {
              parent_id: local_representation[:parent_id]
          }.to_json
      )
      new_foreman_representation = foreman_representation
      new_foreman_representation[:parent_id] = local_representation[:parent_id]
      changes << {
          before: foreman_representation,
          after: new_foreman_representation
      }
    end
    {foreman: changes}
  end

  def generate_local_representation(zone)
    {
        id: zone.id,
        foreman_location_id: zone.foreman_location_id,
        name: zone.name,
        parent_id: zone.parent.try(:foreman_location_id)
    }
  end
end
