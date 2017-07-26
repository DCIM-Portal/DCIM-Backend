class ZonesController < ApplicationController

  before_action :set_zone, only: [:show, :update, :destroy]
  before_action :foreman_locations, :dcim_locations, :foreman_extras, :dcim_extras, only: [:api_zone, :create, :destroy, :update]
  before_action :update_location, only: [:update]
  layout "bmc_page"

  def index
    @zones = Zone.all
    @zone = Zone.new
    @id = Zone.maximum(:id).next + 5 unless @zones.empty?
    respond_to do |format|
      format.html
      format.json {
        render json: @zones.collect {
          |zone| {
            id:  zone.id,
            name: zone.name,
            created_at: zone.created_at,
            url: zone_path(Zone.find(zone.id))
          }
        }
      }
    end
  end

  def api_zone
    @dupe_id = (@dcim_extras.keys & @foreman_extras.keys).each { |x| }
    render :partial => "api_zone"
  end

  def foreman_remove
    params[:zone].each do |foreman_params|
      query = @foreman_resource.api.locations(foreman_params["id"])
      delete = query.delete
    end
    respond_to do |format|
      format.html { redirect_to zones_url }
    end
  end

  def add_location(name)
    locations.post( { name: name }.to_json )
  end

  def foreman_add
    #Add any zones into foreman not already present
    params[:zone].each do |foreman_params|
      add_location( foreman_params["name"] ) unless get_locations.any? { |x| x["name"] == foreman_params["name"] }
    end

    #Update DCIM's zone id to match that in Foreman
    params[:zone].each do |foreman_params|
      get_locations.each do | x |
        Zone.where( name: x["name"] ).update_all( id: x["id"] ) if x["name"] == foreman_params["name"]
      end
    end

    respond_to do |format|
      format.html { redirect_to zones_url }
    end

  end

  def create
    @zone = Zone.new(zone_params)
    respond_to do |format|
      #If successfully can reach Foreman, do the save 
      if !@logger.error?
        if @zone.save
          add_location( params[:zone][:name] ) unless get_locations.any? { |x| x["name"] == params[:zone][:name] }

          #Update new zone in DCIM tool with Foreman's id
          get_locations.each do |x|
            Zone.where( name: params[:zone][:name] ).update_all(id: x["id"] ) if x["name"] == params[:zone][:name]
          end
          format.json { render json: @zone }
        else
          format.html { render json: @zone.errors.full_messages, status: :unprocessable_entity }
        end
      else
        format.json { render json: '["Foreman not reachable.  Unable to save."]', status: "422" }
      end
    end
  end

  def update
    name_invalid = name_check(params["zone"]["name"])
    respond_to do |format|
      if name_invalid == true
        @zone.update(zone_params)
        format.json { render json: @zone.errors.full_messages, status: :unprocessable_entity }
      elsif update_location == 200 && name_invalid == false
        @zone.update(zone_params)
        #format.html { redirect_to(@zone, :notice => "Zone Name Successfully Updated") }
        format.json { render json: @zone, location: @zone }
      else
        format.json { render json: '["Foreman not reachable.  Unable to save."]', status: "422" }
      end
    end
  end

  def show
  end

  def destroy
    if !@logger.error?
      @zone.destroy
      query = @foreman_resource.api.locations(params["id"])
      delete = query.delete
      respond_to do |format|
        format.html { redirect_to zones_url }
      end
    else
      respond_to do |format|
        flash[:error] = "Foreman not reachable.  Unable to delete."
        format.html { render :show }
      end
    end
  end

  def multi_create
    zone_array_params[:zone].each do |zoned_params|
      Zone.create(zoned_params)
    end
    respond_to do |format|
      format.html { redirect_to zones_url }
    end
  end

  def multi_delete
    zone_array_params[:zone].each do |zoned_params|
      Zone.where(id: zoned_params["id"]).destroy_all
    end
    respond_to do |format|
      format.html { redirect_to zones_url }
    end
  end

  private

    def set_zone
      @zone = Zone.find(params[:id])
    end

    def locations
      @foreman_resource.api.locations
    end

    #Get zones within Foreman
    def get_locations
      begin
        result = locations.get
        result["results"]
      rescue Exception => e 
        @logger.error(exception: e)
        []
      end
    end

    #Attempt to update location in Foreman
    def update_location
      begin
        query = @foreman_resource.api.locations(@zone.id)
        result = query.put({name: params[:zone][:name]}.to_json)
        result.code
      rescue Exception => e
        @logger.error(exception: e)
        []
      end
    end

    # Ensure name is valid
    def name_check(args)
      name = args
      if name == @zone.name
        return false
      elsif Zone.where(name: name).empty? && !name.blank?
        return false
      else
        return true
      end
    end

    #Foreman zones list hash
    def foreman_locations
      @foreman_locations = Hash[get_locations.map { |h| h.values_at('id', 'name') }]
    end

    #DCIM zones list hash
    def dcim_locations
      @dcim_locations = Zone.all.map {|hash| [hash["id"], hash["name"]]}.to_h
    end

    #Do we have zones in Foreman that are not in DCIM tool?
    def foreman_extras
      @foreman_extras = (@foreman_locations.to_a - @dcim_locations.to_a).to_h
    end

    #Do we have zones in DCIM tool that are not in Foreman?
    def dcim_extras
      @dcim_extras = (@dcim_locations.to_a - @foreman_locations.to_a).to_h
    end

    def zone_params
      params.require(:zone).permit(:name, :id)
    end

    def zone_array_params
      params.permit(:zone => [:id, :name])
    end

end
