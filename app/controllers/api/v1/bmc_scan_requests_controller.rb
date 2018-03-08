module Api
  module V1
    class BmcScanRequestsController < ApiController
      resource_description do
        name 'BMC Scan Requests'
        short 'Requests that turn into jobs to find undiscovered BMC hosts'
      end

      api! 'List BMC scan requests'
      def index
        # TODO
        super
      end

      api! 'Show a BMC scan request'
      def show
        # TODO
        super
      end

      api! 'Create a BMC scan request'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit a BMC scan request'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete a BMC scan request'
      def destroy
        # TODO
        super
      end
    end
  end
end