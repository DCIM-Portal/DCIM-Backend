class Admin::EnclosureRacksController < AdminController
  before_action :set_enclosure_rack, only: %i[show update destroy]

  def index
    @racks = EnclosureRack.all
    @zones = Zone.all
    @rack = EnclosureRack.new
    respond_to do |format|
      format.html
      format.json { render json: @racks }
    end
  end

  def show
  end

  def create
    @rack = EnclosureRack.new(enclosure_rack_params)
    respond_to do |format|
      if CreateRacks.call(@rack) == false
        format.json { render json: { error: 'Rack already exists or invalid parameter!' }, status: :unprocessable_entity }
      else
        format.json { render json: { message: 'Enclosure Rack created!' }, status: :ok }
      end
    end
  end

  def update; end

  def destroy; end

  private

  def enclosure_rack_params
    params.require(:enclosure_rack).permit(:name, :amount, :start_at, :zone_id, :zero_pad_to, :height)
  end

  def set_enclosure_rack
    @rack = EnclosureRack.find(params[:id])
  end
end
