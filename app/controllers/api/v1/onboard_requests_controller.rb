module Api
  module V1
    class OnboardRequestsController < ApiController
      resource_description do
        name 'Onboard Requests'
        short 'Requests that turn into jobs to register BMC hosts into Foreman by creating systems'
      end

      api! 'List onboard requests'
      def index
        # TODO
        super
      end

      api! 'Show an onboard request'
      def show
        # TODO
        super
      end

      api! 'Create an onboard request'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit an onboard request'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete an onboard request'
      def destroy
        # TODO
        super
      end
    end
  end
end
