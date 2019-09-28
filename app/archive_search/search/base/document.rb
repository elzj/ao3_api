# frozen_string_literal: true

module Search
  module Base
    # Creates an indexable hash for a particular class of object
    class Document
      attr_reader :record

      def initialize(record)
        @record = record
      end

      # Customize this to include or exclude the appropriate data
      def as_json(options = {})
        record.as_json(options)
      end
    end
  end
end
