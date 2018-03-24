module Api
  module V1
    class EnclosureRacksController < ApiController
      resource_description do
        name 'Racks'
        short 'Racks (short for enclosure racks) store enclosures in a vertical column in a zone'
      end

      api! 'List enclosure racks'
      collection!
      def index
        # TODO
        super
      end

      api! 'Show an enclosure rack'
      def show
        # TODO
        super
      end

      api! 'Create an enclosure rack'
      params!
      def create
        # TODO
        super
      end

      api! 'Edit an enclosure rack'
      params!
      def update
        # TODO
        super
      end

      api! 'Delete an enclosure rack'
      def destroy
        # TODO
        super
      end
    end
  end
end
