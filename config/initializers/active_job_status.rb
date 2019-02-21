redis_host = ENV['DCIM_PORTAL_JOB_REDIS_HOST'] || 'localhost'
redis_port = ENV['DCIM_PORTAL_JOB_REDIS_PORT'] || '6379'
redis_db   = ENV['DCIM_PORTAL_JOB_REDIS_DB'] || 2
ActiveJobStatus.store = ActiveSupport::Cache::RedisStore.new "redis://#{redis_host}:#{redis_port}/#{redis_db}"
