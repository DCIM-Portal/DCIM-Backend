# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

zone = ZoneComponent.create!(label: 'US-West')
ComponentProperty.create!(component: zone, key: 'address', value: '123 Fake Street, Springfield, USA')

rack            = Component.create!(label: 'A01', parent: zone)
enclosure       = Component.create!(label: 'U01', parent: rack)
chassis         = Component.create!(label: 'my-server', parent: enclosure)
board           = Component.create!(label: 'my-server-serial', parent: chassis)
_bmc            = Component.create!(label: 'my-server-bmc', parent: board)
disk_controller = Component.create!(label: 'my-server-raid', parent: board)
_disk           = Component.create!(label: 'my-server-disk', parent: disk_controller)
nic             = Component.create!(label: 'my-server-nic', parent: board)
_nic_port       = Component.create!(label: 'my-server-network-eth0', parent: nic)
