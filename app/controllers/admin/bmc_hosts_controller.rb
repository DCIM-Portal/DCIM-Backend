class Admin::BmcHostsController < AdminController
  before_action :set_bmc_host, only: %i[show update destroy]
  include Admin::Filters
  layout 'admin_page'
  add_breadcrumb 'Home', '/'
  add_breadcrumb 'Admin', :admin_path
  add_breadcrumb 'BMC Hosts', :admin_bmc_hosts_path

  BMC_ACTION_WHITELIST = [
    'refresh!',
    'power_on?',
    'power_on',
    'power_on_pxe(persistent: true)',
    'shutdown',
    'power_off',
    'bmc_reset'
  ].freeze

  def index
    @bmc_hosts = BmcHost.all

    pick_filters(:bmc_host, zone_filters, bmc_host_filters)

    respond_to do |format|
      format.html
      format.json { render json: @bmc_hosts }
    end
  end

  def show
    add_breadcrumb @bmc_host.ip_address, admin_bmc_host_path
    respond_to do |format|
      format.html
      format.json { render json: @bmc_host.as_json(include: ['system']) }
    end
  end

  def update
    BmcHostsMultiActionJob.perform_later('refresh!', [@bmc_host.id])
  end

  def multi_action
    respond_to do |format|
      if validate_bmc_host_params
        format.json do
          render json: {
            message: "BMC Action #{params[:bmc_bulk_action][:bmc_action]} successfully" \
            "submitted to #{params[:bmc_bulk_action][:bmc_host_ids].count} BMC host(s).",
            status:  :ok
          }
        end
        format.js do
          flash.now[:bmc_action_notice] =
            "<div class='notice'>BMC Action <strong>#{t(params[:bmc_bulk_action][:bmc_action])}</strong>" \
            "successfully submitted to #{params[:bmc_bulk_action][:bmc_host_ids].count} BMC host(s).</div>"
        end
        BmcHostsMultiActionJob.perform_later(params[:bmc_bulk_action][:bmc_action], params[:bmc_bulk_action][:bmc_host_ids])
      else
        format.json { render json: { message: 'Unpermitted BMC Action', allowed: BMC_ACTION_WHITELIST }, status: :unprocessable_entity }
        format.js do
          flash.now[:bmc_action_alert] = if params[:bmc_bulk_action][:bmc_action] == ''
                                           "<div class='alert'>No BMC Action Selected!  Nothing done.</div>"
                                         elsif params[:bmc_bulk_action][:bmc_host_ids].nil?
                                           "<div class='alert'>No BMC Hosts Selected.  No action taken.</div>"
                                         else
                                           "<div class='alert'>Unpermitted BMC Action <strong>#{params[:bmc_bulk_action][:bmc_action]}</strong>."
                                         end
        end
      end
    end
  end

  def new_modal
    @whitelist = BMC_ACTION_WHITELIST
    selected_hosts = ids_to_bmc_hosts(params[:selected_ids])
    respond_to do |format|
      format.html { render layout: false, locals: { hosts: selected_hosts } }
    end
  end

  def destroy; end

  private

  def set_bmc_host
    @bmc_host = BmcHost.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: { action: 'index' }
  end

  def validate_bmc_host_params
    params[:bmc_bulk_action].permit({ bmc_host_ids: [] }, :bmc_action)
    unless (BMC_ACTION_WHITELIST.include? params[:bmc_bulk_action][:bmc_action]) && !params[:bmc_bulk_action][:bmc_host_ids].nil?
      return false
    end
    true
  end

  def ids_to_bmc_hosts(ids)
    BmcHost.where(id: ids)
  end
end
