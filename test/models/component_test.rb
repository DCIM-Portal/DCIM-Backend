require 'test_helper'

class ComponentTest < ActiveSupport::TestCase
  test 'components have parent-child relationship' do
    c1 = Component.create(label: 'c1')
    c2 = Component.create(label: 'c2', parent: c1)
    assert c2.parent == c1
    assert c1.children.find(c2.id)
  end

  test 'component trees' do
    zone            = Component.create!(label: 'US-West')
    rack            = Component.create!(label: 'A01', parent: zone)
    enclosure       = Component.create!(label: 'U01', parent: rack)
    chassis         = Component.create!(label: 'my-server', parent: enclosure)
    board           = Component.create!(label: 'my-server-serial', parent: chassis)
    bmc             = Component.create!(label: 'my-server-bmc', parent: board)
    disk_controller = Component.create!(label: 'my-server-raid', parent: board)
    disk            = Component.create!(label: 'my-server-disk', parent: disk_controller)
    nic             = Component.create!(label: 'my-server-nic', parent: board)
    nic_port        = Component.create!(label: 'my-server-network-eth0', parent: nic)

    assert_equal('US-West', nic_port.parent.parent.parent.parent.parent.parent.label)
    assert_equal('US-West', disk.parent.parent.parent.parent.parent.parent.label)
    assert(bmc.parent.children.include? disk_controller)

    # zone = Component.create(identifier: 'US-West')
    vlan       = Component.create!(label: '1', parent: zone)
    subnet     = Component.create!(label: '192.168.0.0/24', parent: vlan)
    dhcp_scope = Component.create!(label: '192.168.0.127-192.168.0.254', parent: subnet)
    ip_address = Component.create!(label: '192.168.0.2/32', parent: subnet)

    assert_equal(dhcp_scope, zone.children.find_by(label: '1').children[0].children[0])
    assert(subnet.children.include? ip_address)
    assert(ip_address.parent.children.include? dhcp_scope)
  end

  test 'identifier can be duplicate with siblings' do
    a1 = Component.create(label: 'a1')
    a1.save!
    b1 = Component.create(label: 'b1', parent: a1)
    b1.save!
    b1_duplicate = Component.create(label: 'b1')

    assert_nothing_raised do
      b1_duplicate.parent = a1
      b1_duplicate.save!
    end
  end

  test 'deleting component promotes child components to parent above' do
    zone = Component.create(label: 'zone')
    zone.save!
    rack = Component.create(label: 'rack', parent: zone)
    rack.save!
    enclosure = Component.create(label: 'enclosure', parent: rack)
    enclosure.save!

    rack.destroy!
    enclosure.reload

    assert_equal(zone, enclosure.parent, 'Child was not adopted by grandparent')
  end

  test 'deleting component at root promotes children to root' do
    zone = Component.create(label: 'zone')
    zone.save!
    rack = Component.create(label: 'rack', parent: zone)
    rack.save!

    zone.destroy!
    rack.reload

    assert_nil(rack.parent, 'Child is not at the root')
  end

  test 'roll back transaction if child cannot be adopted by grandparent' do
    zone = Component.create(label: 'zone')
    zone.save!
    rack1 = Component.create(label: 'rack1', parent: zone)
    rack1.save!
    rack2 = Component.create(label: 'rack2', parent: zone)
    rack2.save!

    zone.children[1].expects(:save!).raises(ActiveRecord::ActiveRecordError)

    assert_raises(ActiveRecord::ActiveRecordError) do
      zone.destroy!
    end

    rack1.reload
    rack2.reload
    assert_equal(zone, rack1.parent, 'Child has the wrong parent')
    assert_equal(zone, rack2.parent, 'Child has the wrong parent')
  end

  # test 'Action' do
  #   chassis = Component.create(identifier: 'my-server')
  #
  #   action = Action.new(plan: {
  #                         chassis: chassis
  #                       })
  #   action.execute!
  #
  #   class Action
  #     def execute!
  #       chassis = plan[:chassis]
  #
  #       board = chassis.board
  #       board.boot_mode = 'uefi'
  #       board.next_boot = 'pxe'
  #     end
  #   end
  # end
end
