json.extract! system, :id, :name, :cpu_model, :cpu_cores, :cpu_threads, :cpu_count, :ram_total, :disk_total, :disk_count, :os, :os_release, :sync_status, :created_at, :updated_at
json.url system_url(system, format: :json)
