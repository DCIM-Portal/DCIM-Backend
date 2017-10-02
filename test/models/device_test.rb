require 'test_helper'

class DeviceTest < ActiveSupport::TestCase
  test 'device target is polymorphic' do
    device = devices(:one)
    [bmc_hosts(:one), systems(:one)].each do |target|
      device.target = target
      assert device.save, 'Device should have been saved'
      assert_equal target.class.name, device.target_type
      assert_equal target.id, device.target_id
    end
  end

  test 'device must be in an enclosure' do
    enclosure = enclosures(:one)
    device = Device.new
    device.target = bmc_hosts(:one)
    assert_not device.save, 'Device should not have been created without an enclosure'
    device.enclosure = enclosure
    assert device.save, 'Device should have been saved successfully'
    device.enclosure = nil
    assert_not device.save, 'Device was removed from enclosure, but this should not be possible'
  end

  test 'cannot delete target if device is associated' do
    [bmc_hosts(:minimum), systems(:minimum)].each do |target|
      device = devices(:one).dup
      device.target = target
      assert device.save, 'Device should have been saved'
      assert_raises(ActiveRecord::ActiveRecordError, 'Target should have errored on destroy') { target.destroy }
      assert device.destroy, 'Device should have been destroyed'
      assert target.destroy, 'Target should have been destroyed'
    end
  end

  test 'can delete device if link is not present' do
    device1 = devices(:one)
    assert device1.destroy, 'Device should have been destroyed'
  end

  test 'cannot delete device if link is present' do
    device1 = devices(:one)
    device2 = devices(:two)
    device1.linked_devices << device2
    assert device1.save, 'Device should have saved'
    assert_raises(ActiveRecord::ActiveRecordError, 'Device should have erroed on destroy') { device1.destroy }
    assert_raises(ActiveRecord::ActiveRecordError, 'Linked device should have errored destroyed') { device2.destroy }
  end
end
