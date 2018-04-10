module Api
  module V1
    class EnclosuresController < ApiController
      resource_description do
        name 'Enclosures'
        short 'Ordered lists of devices that are located inside an enclosure rack'
      end

      api! 'List enclosures'
      collection!
      def index
        # TODO
        super
      end

      api! 'Show devices in an enclosure'
      def show
        # TODO
        super
      end

      api! 'Create an enclosure'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit an enclosure'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete an enclosure'
      def destroy
        # TODO
        super
      end

      api! 'Show the data structure of enclosures'
      structure!
      def structure
        super
      end
    end
  end
end
