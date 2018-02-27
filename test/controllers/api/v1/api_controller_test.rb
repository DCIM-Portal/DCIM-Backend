require 'test_helper'

class Api::V1::ApiControllerTest < ActionDispatch::IntegrationTest
  def self.json?(string)
    JSON.parse(string)
    return true
  rescue JSON::ParserError
    return false
  end

  test 'index returns all models' do
    get api_v1_zones_url
    assert_response :success
    Rails.logger.warn @response.body
    assert self.class.json?(@response.body)
  end

  test 'create saves new model' do
    post api_v1_zones_url, params: {
      name: 'TestZone'
    }
    assert_response :success
    assert Zone.find_by(name: 'TestZone')
  end
end
