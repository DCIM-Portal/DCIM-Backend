module Api
  module V1
    class BmcScanRequestsController < JobRequestsController
      resource_description do
        name 'BMC Scan Requests'
        short 'Requests that turn into jobs to find undiscovered BMC hosts'
      end

      protected

      def forbidden_write_columns
        super + %i[status error_message]
      end

      public

      api! 'List BMC scan requests'
      collection!
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

      api! 'Reset a BMC scan request'
      def reset
        # TODO
        super
      end

      api! 'Execute a BMC scan request'
      def execute
        # TODO
        super
      end
    end
  end
end
