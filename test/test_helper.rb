require 'simplecov'
SimpleCov.start 'rails'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'mocha/minitest'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def json?(string)
    JSON.parse(string)
    true
  rescue JSON::ParserError
    false
  end

  def authenticated_header
    token = Knock::AuthToken.new(
      payload:
          {
            sub: 'admin',
            username: 'admin',
            foreman_session_id: 'dummy'
          }
    ).token

    {
      'Authorization' => "Bearer #{token}"
    }
  end
end
