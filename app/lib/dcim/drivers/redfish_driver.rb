# Driver for the DMTF Redfish® API
module Dcim
  module Drivers
    class RedfishDriver < ApplicationDriver
      attr_reader :api

      def initialize(agent)
        super(agent)

        @api = BasicAuthApi.new(
          url: "https://#{@properties[:host]}/",
          username: @properties[:username],
          password: @properties[:password],
          verify_ssl: false
        )

        @maps = CaseInsensitiveHash[YAML.load_file(
          Rails.root.join('app', 'lib', 'dcim', 'drivers', 'redfish_data_map.yaml')
        )]

        @trees = CaseInsensitiveHash[YAML.load_file(
          Rails.root.join('app', 'lib', 'dcim', 'drivers', 'redfish_data_tree.yaml')
        )]
      end

      def collect_facts
        chassis_raw_id_list = redfish_get('Chassis')['Members']
        chassis_id_list = redfish_to_collection(chassis_raw_id_list)

        collect_facts_recursive(next: { chassis: chassis_id_list })
      end

      def collect_facts_recursive(hash)
        current_fetches = hash[:next] || {}
        parent = hash[:parent]
        next_fetches = {}
        current_fetches.each do |tree_node, api_paths|
          api_paths.each do |api_path|
            next_fetches.deep_merge!(collect(tree_node, api_path, parent))
            collect_facts_recursive(next_fetches) unless next_fetches.empty?
          end
        end
      end

      def collect(node, api_path, parent)
        raw_data = redfish_get(api_path)
        tree_node = @trees[node.to_s]
        component = parent
        if tree_node[:component]
          component_type = tree_node[:component].constantize
          component = to_component(component_type, raw_data, parent)
          component.save!
        end
        next_nodes = nil
        if tree_node[:next]
          next_nodes = tree_node[:next].transform_values do |value_list|
            tree_next_to_api_paths(raw_data, value_list)
          end
        end
        {
          parent: component,
          next: next_nodes
        }
      end

      private

      def tree_next_to_api_paths(raw_data, value_list)
        value_list = [value_list] if value_list.is_a?(String)
        output = []
        value_list.each do |value|
          raw_path = raw_data
          value.split('/').each do |raw_key|
            raw_path = raw_path[raw_key]
          end
          if raw_path.is_a?(Array)
            output += redfish_to_collection(raw_path)
          else
            output << raw_path['@odata.id']
          end
        rescue StandardError
          next
        end
        output
      end

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
          if attribute.is_a?(Hash)
            begin
              canonicalize(mapping[raw_key], raw_hash[raw_key], component)
            ensure
              next
            end
          end

          next if raw_hash[raw_key].nil?

          component.properties << ComponentProperty.new(
            key: attribute,
            value: RedfishDataAdapter.adapt(raw_hash[raw_key], raw_key, component),
            source: @agent
          )
        end
      end
    end
  end
end

