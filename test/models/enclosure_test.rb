require 'test_helper'

class EnclosureTest < ActiveSupport::TestCase
  test 'enclosure cannot be deleted if it has devices' do
    enclosure = enclosures(:minimum)
    enclosure.devices << devices(:one)
    assert enclosure.save, 'Should have saved enclosure'
    assert_raises(ActiveRecord::ActiveRecordError, 'Enclosure should have errored on destroy') { enclosure.destroy }
    assert enclosure.devices.destroy_all, 'Should have destroyed all devices in the enclosure'
    assert enclosure.destroy, 'Should have destroyed enclosure'
  end
end
