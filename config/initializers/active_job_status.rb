ActiveJobStatus.store = ActiveSupport::Cache::RedisStore.new (ENV['DCIM_PORTAL_REDIS_HOST'] || "localhost") + ':6379/3'
