require 'test_helper'

class Api::V1::ApplicationSearchTest < ActionDispatch::IntegrationTest
  test 'search supports basic filter' do
    model = BmcHost
    # ?filters[0][]=id=1337
    params = {
      'filters' => {
        '0' => [
          'id=1337'
        ]
      }
    }.deep_stringify_keys

    search = Dcim::Search::ApplicationSearch.search(model, params)
    filters_info = search.filters_info

    assert filters_info.is_a?(Array)
    filter_group = filters_info[0]
    assert filter_group.is_a?(Array)
    filter = filter_group[0]
    assert_equal('id', filter[:key])
    assert_equal('=', filter[:operation])
    assert_equal('1337', filter[:value])
  end

  test 'search with filter group containing multiple items' do
    model = BmcHost
    # ?filters[0][]=id=1337&filters[0][]=zone_id<=1
    params = {
      'filters' => {
        '0' => %w[id=1337 zone_id<=1]
      }
    }.deep_stringify_keys

    search = Dcim::Search::ApplicationSearch.search(model, params)
    filters_info = search.filters_info

    filter_group = filters_info.first
    assert(filter_group.any? do |filter|
      filter[:key] == 'id' &&
          filter[:operation] == '=' &&
          filter[:value] == '1337'
    end)
    assert(filter_group.any? do |filter|
      filter[:key] == 'zone_id' &&
          filter[:operation] == '<=' &&
          filter[:value] == '1'
    end)
  end

  test 'search with multiple filter groups' do
    model = BmcHost
    # ?filters[angels][]=id=1337&filters[angels][]=id=9001&filters[airwaves][]=power_status=on
    params = {
      'filters' => {
        'angels' => %w[id=1337 id=9001],
        'airwaves' => %w[power_status=on]
      }
    }

    search = Dcim::Search::ApplicationSearch.search(model, params)
    filters_info = search.filters_info

    assert_equal(2, filters_info.count)
    first_count = filters_info.first.count
    last_count = filters_info.last.count
    assert_not_equal(first_count, last_count)
    assert_includes([1, 2], first_count)
    assert_includes([1, 2], last_count)
  end

  test 'search with no filters' do
    model = BmcHost
    # ?
    params = {}

    search = Dcim::Search::ApplicationSearch.search(model, params)
    filters_info = search.filters_info

    assert_empty(filters_info)
  end

  test 'search raises Bad Request on invalid filter item' do
    model = BmcHost
    params = {
      'filters' => {
        '0' => %w[id]
      }
    }
    assert_raises(ActionController::BadRequest) do
      Dcim::Search::ApplicationSearch.search(model, params)
    end
  end

  test 'search raises Bad Request on invalid filter field' do
    model = BmcHost
    params = {
      'filters' => {
        '0' => %w[meep=otherwise_parseable]
      }
    }
    assert_raises(ActionController::BadRequest) do
      Dcim::Search::ApplicationSearch.search(model, params)
    end
  end

  test 'search raises Bad Request on invalid filter operation' do
    model = BmcHost
    params = {
      'filters' => {
        '0' => %w[id<=>spaceship_operator_is_unacceptable]
      }
    }
    assert_raises(ActionController::BadRequest) do
      Dcim::Search::ApplicationSearch.search(model, params)
    end
  end

  test 'search raises Bad Request on blank filter value' do
    model = BmcHost
    params = {
      'filters' => {
        '0' => %w[id=]
      }
    }
    assert_raises(ActionController::BadRequest) do
      Dcim::Search::ApplicationSearch.search(model, params)
    end
  end
end
