require 'test_helper'

class Api::V1::ApiControllerTest < ActionDispatch::IntegrationTest
  def self.json?(string)
    JSON.parse(string)
    return true
  rescue JSON::ParserError
    return false
  end

  def authenticated_header
    token = Knock::AuthToken.new(
        {
            payload:
                {
                    sub: 'admin',
                    username: 'admin',
                    foreman_session_id: 'dummy'
                }
        }
    ).token

    {
        'Authorization': "Bearer #{token}"
    }
  end

  test 'index returns all models' do
    get api_v1_zones_url, headers: authenticated_header
    assert_response :success
    assert self.class.json?(@response.body)
  end

  test 'show shows model' do
    get api_v1_zone_url(id: zones(:one).id), headers: authenticated_header
    assert_response :success
    assert self.class.json?(@response.body)
  end

  test 'create saves new model' do
    post api_v1_zones_url, headers: authenticated_header,
         params: {
             name: 'TestZone'
         }
    assert_response :success
    assert Zone.find_by(name: 'TestZone')
  end

  test 'update changes model' do
    test_zone = zones(:one)
    assert_not test_zone.name
    put api_v1_zone_url(id: test_zone.id), headers: authenticated_header,
        params: {
            name: 'UpdatedZone'
        }
    assert_response :success
    assert_equal 'UpdatedZone', Zone.find(test_zone.id).name
  end

  test 'destroy deletes model' do
    test_zone = Zone.new(name: 'DeleteMe')
    test_zone.save!
    delete api_v1_zone_url(id: test_zone.id), headers: authenticated_header
    assert_response :success
    assert_raises ActiveRecord::RecordNotFound do
      test_zone.reload
    end
  end
end
