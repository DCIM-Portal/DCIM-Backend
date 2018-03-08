module Api
  module V1
    class SystemsController < ApiController
      resource_description do
        name 'Systems'
        short 'Analogous to Foreman hosts, systems are computer devices'
      end

      api! 'List systems'
      def index
        # TODO
        super
      end

      api! 'Show a system'
      def show
        # TODO
        super
      end

      api! 'Create a system'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit a system'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete a system'
      def destroy
        # TODO
        super
      end
    end
  end
end