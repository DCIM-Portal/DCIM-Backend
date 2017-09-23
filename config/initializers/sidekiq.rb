Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://' + (ENV['DCIM_PORTAL_REDIS_HOST'] || 'localhost') + ':6379/2' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://' + (ENV['DCIM_PORTAL_REDIS_HOST'] || 'localhost') + ':6379/2' }
  Sidekiq::Logging.logger.level = Logger::DEBUG
end

Sidekiq.default_worker_options['retry'] = 0
