# frozen_string_literal: true

module Search
  module Bookmarks
    class ExternalWorkDocument
      include Search::Shared::TaggableDocument

      WHITELISTED_ATTRIBUTES = %w(
        title summary hidden_by_admin created_at
      ).freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def as_json(options = {})
        record.as_json(
          only: WHITELISTED_ATTRIBUTES
        ).merge(
          bookmarkable_type:  'ExternalWork',
          bookmarkable_join:  { name: "bookmarkable" }
        ).merge(options)
      end
    end
  end
end
