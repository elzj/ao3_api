# frozen_string_literal: true

module Search
  module Bookmarks
    class SeriesDocument
      WHITELISTED_ATTRIBUTES = %w(
        title summary hidden_by_admin created_at restricted complete
      ).freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def as_json(options = {})
        record.as_json(
          only: WHITELISTED_ATTRIBUTES
        ).merge(
          bookmarkable_type:  'Series',
          bookmarkable_join:  { name: "bookmarkable" }
        ).merge(options)
      end
    end
  end
end
