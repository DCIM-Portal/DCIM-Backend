# Driver for the DMTF Redfish® API
module Dcim
  module Drivers
    class RedfishDriver < ApplicationDriver
      CHASSIS_MAP = {
        'chassistype' => 'chassis:type',
        'manufacturer' => 'chassis:brand',
        'model' => 'chassis:model',
        'oem' => {
          'Hp' => {
            'BayNumber' => 'chassis:order'
          }
        },
        'partnumber' => 'chassis:part',
        'powerstate' => 'chassis.board:power_on',
        'sku' => 'chassis:sku',
        'serialnumber' => 'chassis:serial'
      }.freeze
      SYSTEM_MAP = {
        'biosversion' => 'board:bios_version',
        'manufacturer' => 'board:brand',
        'model' => 'board:model',
        'oem' => {
          'Hp' => {
            'Battery' => {
              'Condition' => 'board.disk_controller.battery:health',
              'FirmwareVersion' => 'board.disk_controller.battery:firmware_version',
              'Model' => 'board.disk_controller.battery:model',
              'ProductName' => 'board.disk_controller.battery:name',
              'SerialNumber' => 'board.disk_controller.battery:serial',
              'Spare' => 'board.disk_controller.battery:part'
            }
          }
        },
        'partnumber' => 'board:part',
        'powerstate' => 'board:powered_on',
        'sku' => 'board:sku',
        'serialnumber' => 'board:serial',
        'uuid' => 'board:uuid'
      }.freeze

      def collect_facts
        @api = BasicAuthApi.new(
          url: "https://#{@properties[:host]}/",
          username: @properties[:username],
          password: @properties[:password],
          verify_ssl: false
        )
        chassis_raw_id_list = redfish_get('Chassis')['Members']
        chassis_id_list = redfish_to_collection(chassis_raw_id_list)

        collect_facts_recursive(chassis: chassis_id_list)
      end

      def collect_facts_recursive(hash)
        next_fetches = {}
        hash.each do |operation, api_paths|
          api_paths.each do |api_path|
            next_fetches.deep_merge!(send("collect_#{operation}", api_path))
          end
        end
        collect_facts_recursive(next_fetches) unless next_fetches.empty?
      end

      def collect_chassis(api_path)
        chassis = redfish_get(api_path)
        chassis_to_components(chassis)
        puts("COLLECTING CHASSIS: #{api_path}")
        { system: redfish_to_collection(chassis['Links']['ComputerSystems']) }
      end

      def collect_system(api_path)
        _system = redfish_get(api_path)
        # TODO: turn system into Components
        puts("COLLECTING SYSTEM: #{api_path}")
        {}
      end

      private

      attr_reader :api

      def redfish_get(redfish_id)
        redfish_path = redfish_id.split('/')
        redfish_path.delete_at(0) if redfish_path[0].empty?
        redfish_path.delete_at(0) if redfish_path[0].casecmp('redfish').zero?
        redfish_path.delete_at(0) if redfish_path[0].casecmp('v1').zero?
        query = api.query
        query.append_chain('redfish', ['v1'] + redfish_path)
        CaseInsensitiveHash[query.get.to_h]
      end

      def redfish_to_collection(list)
        collection = []
        list.each do |list_item|
          collection << list_item['@odata.id']
        end
        collection
      end

      def chassis_to_components(raw_chassis)
        serial = raw_chassis['SerialNumber']
        ComponentProperty.where(source: @agent).find_by(key: 'serial')
        component = @agent
                    .components
                    .joins(:properties)
                    .find_by(
                      type: ChassisComponent.name,
                      component_properties: {
                        key: 'serial',
                        value: serial
                      }
                    ) || ChassisComponent.new
        canonicalize(CHASSIS_MAP, raw_chassis, component)
        component.save!
      end

      def canonicalize(map, raw_hash, component)
        map.each do |raw_key, component_path_attribute|
          if component_path_attribute.is_a? Hash
            canonicalize(map[raw_key], raw_hash[raw_key], component)
            next
          end
          component_path, attribute = component_path_attribute.split(':')
          component_path = component_path.split('.')
          next unless component_path.size == 1

          component.properties << ComponentProperty.new(
            key: attribute,
            value: raw_hash[raw_key],
            source: @agent
          )
        end
      end
    end
  end
end

class CaseInsensitiveHash < HashWithIndifferentAccess
  def [](key)
    super convert_key(key)
  end

  protected

  def convert_key(key)
    key.respond_to?(:downcase) ? key.downcase : key
  end
end
