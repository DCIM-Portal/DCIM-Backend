require 'test_helper'

class EnclosureRackTest < ActiveSupport::TestCase
  test 'enclosure rack cannot be deleted if it has enclosures' do
    rack = enclosure_racks(:minimum)
    rack.enclosures << enclosures(:one)
    assert rack.save, 'Should have saved rack'
    assert_raises(ActiveRecord::ActiveRecordError, 'Rack should have errored on destroy') { rack.destroy }
    assert rack.enclosures = [], 'Should have dissociated all enclosures from rack'
    assert rack.destroy, 'Should have destroyed rack'
  end

  test 'rack orientation is between 0 and 359' do
    rack = enclosure_racks(:minimum)
    (0..359).each do |x|
      assert rack.update(orientation: x), "Rack should have accepted orientation #{x}"
    end
    assert_not rack.update(orientation: -1), 'Rack should not have accepted invalid orientation'
    assert_not rack.update(orientation: 360), 'Rack should not have accepted invalid orientation'
  end
end
