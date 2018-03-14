source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# API Documentation Tool
#
# v0.5.3 through v0.5.6 are broken.
# See: https://github.com/Apipie/apipie-rails/issues/559
gem 'apipie-rails', '0.5.2'

# JWT authentication
gem 'knock'

# Rest-Client
gem 'rest-client'

# Sunspot for Rails
gem 'sunspot_rails'
gem 'sunspot_solr'

# Redis store for Rails
gem 'redis-rails'

# Sidekiq for Background Jobs
gem 'sidekiq', '~> 5.1'

# ActiveJob status tracking
gem 'active_job_status', '>= 1.2.1'

# Concurrent Ruby
gem 'concurrent-ruby', require: 'concurrent'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.0.rc1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use Puma as the app server
gem 'puma', '~> 3'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Timezone data for ActiveSupport
gem 'tzinfo-data'

group :development, :test do
  gem 'mocha'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Code coverage
  gem 'simplecov', require: false
  # Static code analysis
  gem 'rubocop', require: false
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.1.5'
  gem 'web-console', '>= 3.5.1'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
  # Test on SQLite3 database
  gem 'sqlite3'
end
