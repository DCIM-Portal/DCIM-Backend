class BruteListsController < ApplicationController

  layout "bmc_page"
  before_action :set_cred, only: [:show, :edit, :update, :destroy]

  def index
    @creds = BruteList.all
  end

  def new
    @cred = BruteList.new
    @cred.brute_list_secrets.build
  end

  def edit
  end

  def create
    @cred = BruteList.new(bmc_credential_params)
    respond_to do |format|
      if @cred.save
        format.html { redirect_to brute_lists_url }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @cred.update(bmc_credential_params)
        @cred.save
        format.html { redirect_to @cred }
      else
        format.html { render :edit }
      end
    end
  end

  def show
    @secrets = BruteListSecret.where(brute_list_id: @cred.id).order('`order` ASC')
  end

  def destroy
    @cred.destroy
    respond_to do |format|
      format.html { redirect_to brute_lists_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cred
      @cred = BruteList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bmc_credential_params
      params.require(:brute_list).permit(:name, brute_list_secrets_attributes: [:username, :password, :order])
    end

end
