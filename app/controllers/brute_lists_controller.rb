class BruteListsController < ApplicationController

  layout "bmc_page"
  before_action :set_cred, only: [:show, :update, :destroy]

  def index
    @creds = BruteList.all
    @cred = BruteList.new
    @cred.brute_list_secrets.build
    @count = BruteList.count
    respond_to do |format|
      format.html
      format.json {
        render json: @creds.collect {
          |cred| {
            id:  cred.id,
            name: cred.name,
            created_at: cred.created_at,
            url: brute_list_path(BruteList.find(cred.id))
          }
        }
      }
    end
  end

  def create
    @cred = BruteList.new(bmc_credential_params)
    respond_to do |format|
      if @cred.save
        format.json { render json: @cred }
      else
        format.json { render json: @cred.errors.full_messages, status: :unprocessable_entity }
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
        format.json { render json: @cred }
      else
        @cred.update(bmc_credential_params)
        format.json { render json: @cred.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def destroy
    name = @cred.name
    begin
      @cred.destroy
      flash[:success] = "Successfully deleted credential list #{ name }"
      redirect_to brute_lists_url
    rescue ActiveRecord::DeleteRestrictionError => e
      @cred.errors.add(:base, e)
      flash[:error] = "#{e}"
      redirect_to @cred
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
