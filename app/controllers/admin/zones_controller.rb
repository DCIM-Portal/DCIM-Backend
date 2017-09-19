class Admin::ZonesController < AdminController

  before_action :set_zone, only: [:show, :update, :destroy]
  before_action :foreman_locations, :dcim_locations, :foreman_extras, :dcim_extras, only: [:check_foreman_locations_synced, :create, :destroy, :update]
  include Admin::Filters
  layout "admin_page"
  add_breadcrumb "Home", "/"
  add_breadcrumb "Admin", :admin_path
  add_breadcrumb "Datacenter Zones", :admin_zones_path

  def index
    @zones = Zone.all
    @zone = Zone.new
    respond_to do |format|
      format.html
      format.json { render json: @zones }
    end
  end

  def check_foreman_locations_synced
    render :partial => "check_foreman_locations_synced"
  end

  def foreman_remove
    params[:zone].each do |foreman_params|
      query = locations(foreman_params["id"])
      delete = query.delete
    end
    respond_to do |format|
      format.html { redirect_to admin_zones_url }
    end
  end

  def add_location(name)
    locations.post( { name: name }.to_json )
  end

  def foreman_add
    #Add any zones into foreman not already present
    params[:zone].each do |foreman_params|
      result = add_location( foreman_params["name"] ) unless get_locations.any? { |x| x["name"] == foreman_params["name"] }
      new_foreman_location_id = JSON.parse(result.body)["id"]
      Zone.where(name: foreman_params["name"]).update(foreman_location_id: new_foreman_location_id)
    end
    respond_to do |format|
      format.html { redirect_to admin_zones_url }
    end
  end

  def create
    @zone = Zone.new(zone_params)
    respond_to do |format|
      #If successfully can reach Foreman, do the save 
      if !@logger.error?
        if @zone.save
          result = add_location( params[:zone][:name] ) unless get_locations.any? { |x| x["id"] == params[:zone][:id] }
          new_foreman_location_id = JSON.parse(result.body)["id"]
          #Update new zone in DCIM tool with Foreman's id
          @zone.update(foreman_location_id: new_foreman_location_id)
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
        format.json { render json: @zone }
      else
        format.json { render json: '["Foreman not reachable.  Unable to save."]', status: "422" }
      end
    end
  end

  def show
    add_breadcrumb @zone.name, admin_zone_path

    pick_filters(:bmc_host, bmc_host_filters)

    respond_to do |format|
      format.html
      format.json { render json: @zone }
    end
  end

  def destroy
    if !@logger.error?
      if @zone.foreman_location_id
        query = @foreman_resource.api.locations(@zone.foreman_location_id)
        delete = query.delete
      end
      @zone.destroy
      respond_to do |format|
        format.html { redirect_to admin_zones_url }
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
      query = locations(zoned_params["id"])
      foreman_location_id = query.get["id"]
      dcim_zone = Zone.new(name: zoned_params["name"])
      dcim_zone.foreman_location_id = foreman_location_id
      dcim_zone.save
    end
    respond_to do |format|
      format.html { redirect_to admin_zones_url }
    end
  end

  def multi_delete
    zone_array_params[:zone].each do |zoned_params|
      Zone.where(name: zoned_params["name"]).destroy_all
    end
    respond_to do |format|
      format.html { redirect_to admin_zones_url }
    end
  end

  private

    def set_zone
      @zone = Zone.find(params[:id])
    end

    def locations(*args)
      @foreman_resource.api.locations(*args)
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
        query = locations(@zone.foreman_location_id)
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
      @foreman_locations = get_locations.map { |h| h.values_at('id', 'name') }
    end

    #DCIM zones list hash
    def dcim_locations
      @dcim_locations = Zone.all.map {|hash| [hash["foreman_location_id"], hash["name"]]}
    end

    #Do we have zones in Foreman that are not in DCIM tool?
    def foreman_extras
      @foreman_extras = @foreman_locations - @dcim_locations
    end

    #Do we have zones in DCIM tool that are not in Foreman?
    def dcim_extras
      @dcim_extras = @dcim_locations - @foreman_locations
    end

    def zone_params
      params.require(:zone).permit(:name, :id)
    end

    def zone_array_params
      params.permit(:zone => [:id, :name])
    end

end
