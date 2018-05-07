module Api
  module V1
    module BmcHostsControllerPower
      extend ActiveSupport::Concern
      extend Apipie::DSL::Concern

      api! 'Get power information'
      def power_get
        # TODO
      end

      api! 'Execute power action'
      def power_set
        # TODO
      end
    end
  end
end