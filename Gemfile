source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Rails, what this project is written in
gem 'rails', '~> 6'
# Use Puma as the app server
gem 'puma', '>= 4.3.1', '< 5'

gem 'dotenv-rails', groups: %i[development test]

# Use PostgreSQL as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'

# API Documentation Tool
gem 'apipie-rails', '0.7.2'

# GraphQL API
gem 'graphiql-rails', group: :development
gem 'graphql'

# JWT authentication
gem 'knock'

# REST Client
gem 'rest-client'

# Testing for REST Client
gem 'webmock', '~> 3.5'

# Cross-Origin Resource Sharing
gem 'rack-cors'

# Pagination for ActiveRecord
gem 'will_paginate'

# Sidekiq for Background Jobs
gem 'sidekiq', '~> 5'
gem 'sidekiq-batch'

# ActiveJob status tracking
gem 'active_job_status', '~> 1.2'

# Concurrent Ruby
gem 'concurrent-ruby', require: 'concurrent'

# Timezone data for ActiveSupport
gem 'tzinfo-data'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  gem 'mocha'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Code coverage
  gem 'simplecov', require: false
  # Static code analysis
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  # Test on SQLite3 database
  gem 'sqlite3', '~> 1.3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end
