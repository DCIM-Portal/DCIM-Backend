redis_host = ENV['DCIM_PORTAL_REDIS_HOST'] || 'localhost'
ActiveJobStatus.store = ActiveSupport::Cache::RedisStore.new "redis://#{redis_host}:6379/3"
