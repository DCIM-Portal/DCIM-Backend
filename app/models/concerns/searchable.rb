module Searchable
  extend ActiveSupport::Concern

  def self.type_to_sunspot_type(input)
    case input
    when :datetime
      return :time
    end
    input
  end

  included do
    unless self.respond_to?(:searchables)
      def self.searchables
        list = []
        self.columns_hash.each do |hash|
          name = hash[0]
          type = Searchable.type_to_sunspot_type(hash[1].type)

          list << [type, name]
        end
        list
      end
    end

    searchable do
      p self.name.constantize.searchables
      self.name.constantize.searchables.each do |item|
        method = item.shift
        send method, *item
      end
    end
  end
end
