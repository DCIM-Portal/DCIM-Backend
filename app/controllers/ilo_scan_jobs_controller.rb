class IloScanJobsController < ApplicationController
  before_action :set_ilo_scan_job, only: [:show, :edit, :update, :destroy]

  # GET /ilo_scan_jobs
  # GET /ilo_scan_jobs.json
  def index
    @ilo_scan_jobs = IloScanJob.all
  end

  # GET /ilo_scan_jobs/1
  # GET /ilo_scan_jobs/1.json
  def show
  end

  # GET /ilo_scan_jobs/new
  def new
    @ilo_scan_job = IloScanJob.new
  end

  # GET /ilo_scan_jobs/1/edit
  def edit
  end

  # POST /ilo_scan_jobs
  # POST /ilo_scan_jobs.json
  def create
    @ilo_scan_job = IloScanJob.new(ilo_scan_job_params)
    @ilo_scan_job.status = "Waiting for Job to Begin..."

    respond_to do |format|
      if @ilo_scan_job.save
        format.html { redirect_to @ilo_scan_job, notice: 'Ilo scan job was successfully created.' }
        format.json { render :show, status: :created, location: @ilo_scan_job }
        ScanJob.perform_later(@ilo_scan_job)
      else
        format.html { render :new }
        format.json { render json: @ilo_scan_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ilo_scan_jobs/1
  # PATCH/PUT /ilo_scan_jobs/1.json
  def update
    respond_to do |format|
      if @ilo_scan_job.update(ilo_scan_job_params)
        format.html { redirect_to @ilo_scan_job, notice: 'Ilo scan job was successfully updated.' }
        format.json { render :show, status: :ok, location: @ilo_scan_job }
      else
        format.html { render :edit }
        format.json { render json: @ilo_scan_job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ilo_scan_jobs/1
  # DELETE /ilo_scan_jobs/1.json
  def destroy
    @ilo_scan_job.destroy
    respond_to do |format|
      format.html { redirect_to ilo_scan_jobs_url, notice: 'Ilo scan job was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ilo_scan_job
      @ilo_scan_job = IloScanJob.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ilo_scan_job_params
      params.require(:ilo_scan_job).permit(:start_ip, :end_ip, :ilo_username, :ilo_password)
    end
end
