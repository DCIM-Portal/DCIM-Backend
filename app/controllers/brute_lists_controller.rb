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
    param_invalid = param_check(params["brute_list"]["brute_list_secrets_attributes"])
    name_invalid = name_check(params["brute_list"]["name"])
    respond_to do |format|
      if param_invalid == false && name_invalid == false
        BruteListSecret.where(brute_list_id: @cred.id).delete_all
        @cred.update(bmc_credential_params)
        @cred.save
        format.html { redirect_to @cred }
      else
        @cred.update(bmc_credential_params)
        format.html { render :show }
      end
    end
  end

  def show
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

    # Since we are deleting associated collection, check parameters for any errors
    def param_check(args)
      if args.inspect != "nil"
        secret_keys = args.keys
        secret_keys.each do |x|
          @check = args[x].values.any? {|v| v.blank?}
          break if @check == true
        end
        return @check
      end
    end

    # Ensure name is valid
    def name_check(args)
      name = args
      if name == @cred.name
        return false
      elsif BruteList.where(name: name).empty? && !name.blank?
        return false
      else
        return true
      end
    end



    # Never trust parameters from the scary internet, only allow the white list through.
    def bmc_credential_params
      params.require(:brute_list).permit(:name, brute_list_secrets_attributes: [:username, :password, :order])
    end

end
