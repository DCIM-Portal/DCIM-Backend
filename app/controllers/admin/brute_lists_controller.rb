class Admin::BruteListsController < AdminController
  before_action :set_cred, only: %i[show update destroy]

  def index
    @creds = BruteList.all
    @cred = BruteList.new
    @cred.brute_list_secrets.build
    @count = BruteList.count
    respond_to do |format|
      format.html
      format.json { render json: @creds }
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
    param_invalid = param_check(params['brute_list']['brute_list_secrets_attributes'])
    name_invalid = name_check(params['brute_list']['name'])
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

  def show; end

  def destroy
    name = @cred.name
    begin
      @cred.destroy
      flash[:success] = "Successfully deleted credential list #{name}"
      redirect_to admin_brute_lists_url
    rescue ActiveRecord::DeleteRestrictionError => e
      @cred.errors.add(:base, e)
      flash[:error] = e.to_s
      redirect_to [:admin, @cred]
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cred
    @cred = BruteList.find(params[:id])
  end

  # Since we are deleting associated collection, check parameters for any errors
  # XXX: Bad name for this method
  def param_check(args)
    args = args.to_unsafe_h if args.is_a? ActionController::Parameters
    return true unless args.respond_to? :each_value

    args.each_value do |arg|
      return true if arg.values.any?(&:blank?)
    end
    false
  end

  # Ensure name is valid
  # XXX: Bad name for this method
  def name_check(args)
    name = args
    return false if name == @cred.name || (BruteList.where(name: name).empty? && name.present?)

    true
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bmc_credential_params
    params.require(:brute_list).permit(:name, brute_list_secrets_attributes: %i[username password order])
  end
end
