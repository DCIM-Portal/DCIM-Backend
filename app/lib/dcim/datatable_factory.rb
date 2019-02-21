# All records:
#  /datatable/bmc_hosts
#   "Datatable for all BmcHosts"
# Records belonging to category:
#  /datatable/bmc_hosts/zone/1
#   "Datatable for BmcHosts in Zone 1"
# Records in category not in another category:
#  /datatable/bmc_hosts/zone/1/not-in/enclosure_rack
#   "Datatable for BmcHosts in Zone 1 that are not in an EnclosureRack"
# Records in category in another category:
#  /datatable/bmc_hosts/zone/1/in/enclosure_rack
#   "Datatable for BmcHosts in Zone 1 that are in any EnclosureRack"
# Records not in category:
#  /datatable/bmc_hosts/not-in/enclosure_rack
#   "Datatable for BmcHosts that are not in an EnclosureRack"

module Dcim
  class DatatableFactory
    MODIFIERS = ['in', 'not-in'].freeze

    def initialize(view_context, params, namespace = '')
      @params = params
      @view_context = view_context
      @route = parse_params_route(params[:route])
      @namespace = namespace
    end

    def instance
      klass_name = @route[:model_name].singularize.camelize + 'Datatable'
      begin
        klass = (@namespace + '::' + klass_name).constantize
      rescue NameError
        klass = ApplicationDatatable
      end
      @instance ||= klass.new(@view_context, @params, @route)
    end

    def modifier?(string)
      MODIFIERS.include? string
    end

    def to_path
      path = "#{@route[:model_name]}/#{@route[:category_name]}/#{@route[:category_id]}"
      path += modifier_to_path
      route_method = 'datatable_path'
      route_method = @namespace.gsub('::', '_').downcase + '_' + route_method unless @namespace.empty?
      @view_context.send(route_method, route: path)
    end

    # Debug
    attr_reader :route

    private

    def parse_params_route(route)
      return route unless route.is_a?(String)

      route_split = route.split('/')
      route = {}
      current_modifier = nil

      route_split.each do |route_segment|
        if !route[:model_name]
          route[:model_name] = route_segment
        elsif modifier?(route_segment)
          current_modifier = route_segment
          route[:modifiers] ||= {}
          route[:modifiers][current_modifier] ||= []
        elsif current_modifier
          route[:modifiers][current_modifier] << route_segment
        elsif !route[:category_name]
          route[:category_name] = route_segment
        elsif !route[:category_id]
          route[:category_id] = route_segment
        else
          raise ActionController::RoutingError, 'Not Found'
        end
      end

      route
    end

    def modifier_to_path
      path = ''
      if @route[:modifiers].respond_to? :each
        @route[:modifiers].each do |modifier_name, modifier_values|
          path += "/#{modifier_name}"
          if modifier_values.respond_to? :each
            modifier_values.each do |modifier_value|
              path += "/#{modifier_value}"
            end
          else
            path += "/#{modifier_values}"
          end
        end
      end

      path
    end
  end
end
