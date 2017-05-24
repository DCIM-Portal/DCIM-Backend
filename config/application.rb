require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DcimPortal
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :sidekiq
    config.time_zone = 'Central Time (US & Canada)'
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
  end
end

module ForemanCreds 
  class Application < Rails::Application
    config.foreman = config_for(:foreman)
  end
end
