json.extract! ilo_scan_job, :id, :start_ip, :end_ip, :ilo_username, :ilo_password, :status, :created_at, :updated_at
json.url ilo_scan_job_url(ilo_scan_job, format: :json)