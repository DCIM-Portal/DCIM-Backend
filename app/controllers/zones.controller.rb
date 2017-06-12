class ZonesController < ApplicationController

  before_action :set_zone, only: [:show, :edit, :update, :destroy]
  before_action :foreman_locations, :dcim_locations, :foreman_extras, :dcim_extras, only: [:api_zone]
  layout "bmc_page"

  def index
    @zones = Zone.all
  end

  def api_zone
    @dupe_id = (@dcim_extras.keys & @foreman_extras.keys).each { |x| }
    render :partial => "api_zone"
  end

  def new
    @zone = Zone.new
    @id = Zone.maximum(:id).next + 5
  end

  def edit
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

  def foreman_add
    get_locations

    #Add any zones into foreman not already present
    params[:zone].each do |foreman_params|
      query.post({ name: foreman_params["name"] }) unless @result["results"].any? { |x| x["name"] == foreman_params["name"] }
    end

    #Rebuild Foreman's zone list to get new zone id
    get_locations

    #Update DCIM's zone id to match that in Foreman
    params[:zone].each do |foreman_params|
      @result["results"].each do | x |
        Zone.where( name: x["name"] ).update_all( id: x["id"] ) if x["name"] == foreman_params["name"]
      end
    end

    respond_to do |format|
      format.html { redirect_to zones_url }
    end

  end

  def create
    #Create ActiveRecord object with permitted params
    @zone = Zone.new(zone_params)

    #Retrieve zones list from Foreman
    get_locations
    respond_to do |format|

      #If we successfully save the ActiveRecord object, add it to Foreman
      if @zone.save
        @query.post({ name: params[:zone][:name] }) unless @result["results"].any? { |x| x["name"] == params[:zone][:name] }

        #Rebuild Foreman's zone list to get new zone id
        get_locations

        #Update new zone in DCIM tool with Foreman's id
        @result["results"].each do |x|
          Zone.where( name: params[:zone][:name] ).update_all(id: x["id"] ) if x["name"] == params[:zone][:name]
        end

        format.html { redirect_to zones_url }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @zone.update(zone_params)

        #Update in Foreman
        query = @foreman_resource.api.locations(@zone.id)
        result = query.update({name: params[:zone][:name]})

        #If Foreman save is succssful, save into DCIM
        if result.code == 200
          @zone.save
          format.html { redirect_to(@zone, :notice => "Zone Name Successfully Updated") }
          format.json { respond_with_bip(@zone)  }
        else
          format.html { render :edit }
          format.json { render json: @zone.errors.full_messages }
        end
      end
    end
  end

  def show
  end

  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to zones_url }
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

    #Get zones within Foreman
    def get_locations
      @query = @foreman_resource.api.locations
      @result = @query.get
    end

    #Foreman zones list hash
    def foreman_locations
      get_locations
      @foreman_locations = Hash[@result["results"].map { |h| h.values_at('id', 'name') }]
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
