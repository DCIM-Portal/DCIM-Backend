Apipie.configure do |config|
  config.app_name                = 'Rails DCIM Portal'
  config.doc_base_url            = '/apipie'
  config.api_base_url            = '/api'
  config.default_version         = '1'
  config.app_info = %(
  Rails DCIM Portal is an early development Ruby on Rails implementation of a data center inventory management system that integrates with Foreman.
  )
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"

  config.translate = false
  config.default_locale = nil
end
