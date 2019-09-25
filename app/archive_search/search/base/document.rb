# frozen_string_literal: true

module Search
  module Base
    class Document
      attr_reader :record

      def initialize(record)
        @record = record
      end

      def to_hash
        record.as_json(root: false)
      end
    end
  end
end
