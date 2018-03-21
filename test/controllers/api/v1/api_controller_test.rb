require 'test_helper'

class Api::V1::ApiControllerTest < ActionDispatch::IntegrationTest
  test 'index returns all models' do
    get api_v1_brute_lists_url,
        headers: authenticated_header
    assert_response :success
    assert json?(@response.body)
  end

  test 'show shows model' do
    get api_v1_brute_list_url(id: brute_lists(:one).id),
        headers: authenticated_header
    assert_response :success
    assert json?(@response.body)
  end

  test 'show encounters error' do
    get api_v1_brute_list_url(id: -1),
        headers: authenticated_header
    assert_response :not_found
    assert json?(@response.body)
  end

  test 'create saves new model' do
    post api_v1_brute_lists_url,
         headers: authenticated_header,
         params: {
           name: 'TestBruteList'
         }
    assert_response :success
    assert BruteList.find_by(name: 'TestBruteList')
  end

  test 'update changes model' do
    test_brute_list = brute_lists(:one)
    assert_not_equal 'UpdatedBruteList', test_brute_list.name
    put api_v1_brute_list_url(id: test_brute_list.id),
        headers: authenticated_header,
        params: {
          name: 'UpdatedBruteList'
        }
    assert_response :success
    assert_equal 'UpdatedBruteList', BruteList.find(test_brute_list.id).name
  end

  test 'destroy deletes model' do
    test_brute_list = BruteList.new(name: 'DeleteMe')
    test_brute_list.save!
    delete api_v1_brute_list_url(id: test_brute_list.id),
           headers: authenticated_header
    assert_response :success
    assert_raises ActiveRecord::RecordNotFound do
      test_brute_list.reload
    end
  end
end
