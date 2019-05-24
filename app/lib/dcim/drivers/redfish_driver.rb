# Driver for the DMTF Redfish® API
module Dcim
  module Drivers
    class RedfishDriver < ApplicationDriver
      CHASSIS_MAP = {
        'chassistype' => 'type',
        'manufacturer' => 'brand',
        'model' => 'model',
        'oem' => {
          'Hp' => {
            'BayNumber' => 'order'
          }
        },
        'partnumber' => 'part',
        'sku' => 'sku',
        'serialnumber' => 'serial'
      }.freeze
      SYSTEM_MAP = {
        'biosversion' => 'bios_version',
        'manufacturer' => 'brand',
        'model' => 'model',
        'partnumber' => 'part',
        'powerstate' => 'powered_on',
        'sku' => 'sku',
        'serialnumber' => 'serial',
        'uuid' => 'uuid'
      }.freeze
      CPU_MAP = {
        'Id' => 'socket',
        'InstructionSet' => 'instruction_set',
        'ProcessorArchitecture' => 'architecture',
        'Manufacturer' => 'brand',
        'MaxSpeedMHz' => 'max_speed_megahertz',
        'Model' => 'model',
        'TotalCores' => 'cores',
        'TotalThreads' => 'threads'
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

        collect_facts_recursive(next: { chassis: chassis_id_list })
      end

      def collect_facts_recursive(hash)
        current_fetches = hash[:next]
        parent = hash[:parent]
        next_fetches = {}
        current_fetches.each do |operation, api_paths|
          api_paths.each do |api_path|
            next_fetches.deep_merge!(send("collect_#{operation}", api_path, parent))
          end
        end
        collect_facts_recursive(next_fetches) unless next_fetches.empty?
      end

      def collect_chassis(api_path, parent)
        chassis = redfish_get(api_path)
        chassis_component = chassis_to_component(chassis, parent)
        chassis_component.save!
        {
          parent: chassis_component,
          next: {
            system: redfish_to_collection(chassis['Links']['ComputerSystems'])
          }
        }
      end

      def collect_system(api_path, parent)
        system = redfish_get(api_path)
        board_component = system_to_component(system, parent)
        board_component.save!
        {
          parent: board_component,
          next: {
            cpu_list: [system['Processors']['@odata.id']]
          }
        }
      end

      def collect_cpu_list(api_path, parent)
        cpu_list = redfish_get(api_path)
        {
          parent: parent,
          next: {
            cpu: redfish_to_collection(cpu_list['Members'])
          }
        }
      end

      def collect_cpu(api_path, parent)
        cpu = redfish_get(api_path)
        cpu_component = cpu_to_component(cpu, parent)
        cpu_component.save!
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

      def chassis_to_component(raw_chassis, parent_component)
        serial = raw_chassis['SerialNumber']
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
        component.agents << @agent
        canonicalize(CHASSIS_MAP, raw_chassis, component)
        component.parent = parent_component
        component
      end

      def system_to_component(raw_system, parent_component)
        serial = raw_system['SerialNumber']
        component = @agent
                    .components
                    .joins(:properties)
                    .find_by(
                      type: BoardComponent.name,
                      component_properties: {
                        key: 'serial',
                        value: serial
                      }
                    ) || BoardComponent.new
        component.agents << @agent
        canonicalize(SYSTEM_MAP, raw_system, component)
        component.parent = parent_component
        component
      end

      def cpu_to_component(raw_cpu, parent_component)
        id = raw_cpu['Id']
        component = parent_component
                    .children
                    .joins(:properties)
                    .find_by(
                      type: CpuComponent.name,
                      component_properties: {
                        key: 'socket',
                        value: id
                      }
                    ) || CpuComponent.new
        component.agents << @agent
        canonicalize(CPU_MAP, raw_cpu, component)
        component.parent = parent_component
        component
      end

      def canonicalize(map, raw_hash, component)
        map.each do |raw_key, attribute|
          if attribute.is_a? Hash
            canonicalize(map[raw_key], raw_hash[raw_key], component)
            next
          end

          next if raw_hash[raw_key].nil?

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
