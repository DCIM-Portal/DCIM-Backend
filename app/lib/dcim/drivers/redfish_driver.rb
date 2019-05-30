# Driver for the DMTF Redfish® API
module Dcim
  module Drivers
    class RedfishDriver < ApplicationDriver
      def initialize(agent)
        super(agent)

        @maps = CaseInsensitiveHash[YAML.load_file(
          Rails.root.join('app', 'lib', 'dcim', 'drivers', 'redfish_data_map.yaml')
        )]
      end

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
        chassis_component = to_component(ChassisComponent, chassis, parent)
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
        board_component = to_component(BoardComponent, system, parent)
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
        cpu_component = to_component(CpuComponent, cpu, parent)
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

      def to_component(component_type, raw_data, parent_component)
        mapping = @maps[component_type.name][:MAPPING]
        raw_identifier = @maps[component_type.name][:IDENTIFIER]
        raw_identifier_value = raw_data[raw_identifier]
        component_identifier = mapping[raw_identifier]
        if parent_component.method_exists? :children
          component =
            find_component(parent_component.children, component_type, component_identifier, raw_identifier_value)
        end
        if @agent.method_exists? :components
          component ||=
            find_component(@agent.components, component_type, component_identifier, raw_identifier_value)
        end
        component ||= component_type.new
        component.agents << @agent
        canonicalize(mapping, raw_data, component)
        component.parent = parent_component
        component
      end

      def find_component(collection, component_type, property_key, property_value)
        collection
          .joins(:properties)
          .find_by(
            type: component_type.name,
            component_properties: {
              key: property_key,
              value: property_value
            }
          )
      end

      def canonicalize(mapping, raw_hash, component)
        mapping.each do |raw_key, attribute|
          if attribute.is_a? Hash
            canonicalize(mapping[raw_key], raw_hash[raw_key], component)
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
