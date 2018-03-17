module Api
  module V1
    class BruteListsController < ApiController
      resource_description do
        name 'Credentials Lists'
        short 'Ordered lists of usernames and passwords to try brute force authentication attacks on BMC hosts found by BMC scan jobs'
      end

      api! 'List credentials lists'
      def index
        # TODO
        super
      end

      api! 'Show credentials in a credentials list'
      def show
        # TODO
        super
      end

      api! 'Create a credentials list'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit a credentials list'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete a credentials list and all of its credentials'
      def destroy
        # TODO
        super
      end
    end
  end
end
