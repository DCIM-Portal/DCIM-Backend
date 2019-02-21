redis_config = {
  url: 'redis://' + (ENV['DCIM_PORTAL_JOB_REDIS_HOST'] || 'localhost') +
       ':' + (ENV['DCIM_PORTAL_JOB_REDIS_PORT'] || '6379') +
       '/' + (ENV['DCIM_PORTAL_JOB_REDIS_DB'] || '2')
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  Sidekiq::Logging.logger.level = Logger::DEBUG
end

Sidekiq.default_worker_options['retry'] = 0
