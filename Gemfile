source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Materialize
gem 'materialize-sass'

# Font-Awesome
gem 'font-awesome-sass', '4.7.0'

# Rest-Client
gem 'rest-client'

# Redis store for Rails
gem 'redis-rails'

# Sidekiq for Background Jobs
gem 'sidekiq', '5.0.4'

# ActiveJob status tracking
gem 'active_job_status', '>= 1.2.1'

# Thread for concurrent processes
gem 'thread'

# Momentjs for Javascript date conversions
gem 'momentjs-rails'

# Local Time
gem 'local_time'

# Locales in Coffeescript
gem 'i18n-js'

# Breadcrumbs
gem 'breadcrumbs_on_rails'

# Jquery DataTables
gem 'jquery-datatables'

# Server Side Datatables
gem 'ajax-datatables-rails'

# Jquery Serialize Objects for Rails
gem 'jquery-serialize-object-rails'

# Render Async for our API calls
gem 'render_async'

# Concurrent Ruby
gem 'concurrent-ruby', require: 'concurrent'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.4'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use Puma as the app server
gem 'puma', '3.9.1'
# Use SCSS for stylesheets
gem 'sass-rails', '5.0.6'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '4.2.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '5.0.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.7.0'
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
end
