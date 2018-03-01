require 'test_helper'

class Api::V1::UserTokenControllerTest < ActionDispatch::IntegrationTest
  test 'create returns expected output' do
    auth_token = mock
    auth_token.expects(:token).returns('mock_string')
    Api::V1::UserTokenController.any_instance.expects(:authenticate).returns(true)
    Api::V1::UserTokenController.any_instance.expects(:auth_token).returns(auth_token)
    post api_v1_auth_user_token_url, params: {
      auth: {
        username: 'foo',
        password: 'bar'
      }
    }
    assert_response :created

    hash = JSON.parse(@response.body)
    assert hash.is_a?(Hash)
    assert_equal('mock_string', hash['jwt'])
  end

  test 'create returns HTTP 404 with invalid credentials' do
    Api::V1::UserTokenController
      .any_instance
      .expects(:authenticate)
      .raises(Knock.not_found_exception_class)
    post api_v1_auth_user_token_url, params: {
      auth: {
        username: 'whatever',
        password: "doesn't matter"
      }
    }
    assert_response :not_found
  end
end
