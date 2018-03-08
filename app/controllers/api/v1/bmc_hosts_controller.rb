module Api
  module V1
    class BmcHostsController < ApiController
      resource_description do
        name 'BMC Hosts'
        short 'Power control devices'
      end

      api! 'List BMC hosts'
      def index
        # TODO
        super
      end

      api! 'Show a BMC host'
      def show
        # TODO
        super
      end

      api! 'Create a BMC host'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit a BMC host'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete a BMC host'
      def destroy
        # TODO
        super
      end
    end
  end
end