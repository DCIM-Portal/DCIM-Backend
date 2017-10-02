require 'test_helper'

class DeviceLinkTest < ActiveSupport::TestCase
  setup do
    @device1 = devices(:one)
    @device2 = devices(:two)
  end

  test 'unlinked devices' do
    assert_empty @device1.linked_devices
    assert_empty @device2.linked_devices
  end

  test 'link created both ways' do
    assert_not @device1.linked_devices.include?(@device2), 'Device should not already be linked'
    assert_not @device2.linked_devices.include?(@device1), 'Device should not already be linked bidirectionally'
    @device1.linked_devices << @device2
    assert @device1.save, 'Device should have saved'
    assert @device1.linked_devices.include?(@device2), 'Device link not established'
    assert @device2.linked_devices.include?(@device1), 'Device link not established bidirectionally'
  end

  test 'link deleted both ways' do
    @device1.linked_devices << @device2
    assert @device2.linked_devices.include?(@device1), 'Device link not established bidirectionally'
    @device1.linked_devices.destroy(@device2)
    assert_not @device1.linked_devices.include?(@device2), 'Device should not be linked anymore'
    assert_not @device2.linked_devices.include?(@device1), 'Device should not be linked back anymore'
  end
end
