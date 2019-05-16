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
        chassis_list = []
        chassis_id_list.each do |chassis_id|
          chassis = redfish_get(chassis_id)
          chassis_list << chassis
        end

        systems_raw_id_list = redfish_get('Systems')['Members']
        systems_id_list = redfish_to_collection(systems_raw_id_list)
        systems_list = []
        systems_id_list.each do |system_id|
          system = redfish_get(system_id)
          systems_list << system
        end

        puts chassis_list.to_json
        puts systems_list.to_json
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

      def chassis_list_to_components(chassis_list)
        chassis_list.each do |chassis|
          @agent.components
          # chassis_component = Component.new()
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
