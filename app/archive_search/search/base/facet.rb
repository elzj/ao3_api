# frozen_string_literal: true

module Search
  module Base
    # A simple wrapper for search aggregation data
    class Facet
      attr_reader :id, :name, :count

      def initialize(id:, name:, count:)
        @id = id
        @name = name
        @count = count
      end
    end
  end
end
