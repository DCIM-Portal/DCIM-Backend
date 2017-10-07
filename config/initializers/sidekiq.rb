redis_config = {
  url: 'redis://' + (ENV['DCIM_PORTAL_REDIS_HOST'] || 'localhost') +
       ':' + (ENV['DCIM_PORTAL_REDIS_PORT'] || '6379') +
       '/' + (ENV['DCIM_PORTAL_REDIS_DB_FOR_SIDEKIQ'] || '1')
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  Sidekiq::Logging.logger.level = Logger::DEBUG
end

Sidekiq.default_worker_options['retry'] = 0
