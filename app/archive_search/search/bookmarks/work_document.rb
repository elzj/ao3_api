# frozen_string_literal: true

module Search
  module Bookmarks
    class WorkDocument
      WHITELISTED_ATTRIBUTES = %w[
        complete created_at hidden_by_admin posted
        restricted revised_at summary title word_count
      ].freeze

      INDEXED_METHODS = %w[
        archive_warning_ids
        category_ids
        character_ids
        collection_ids
        creators
        fandom_ids
        filter_ids
        freeform_ids
        pseud_ids
        rating_ids
        relationship_ids
        tag
        work_types
      ].freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def to_hash
        record.as_json(
          root: false,
          only: WHITELISTED_ATTRIBUTES,
          methods: INDEXED_METHODS,
        ).merge(
          language_id:        record.language_short,
          anonymous:          record.anonymous?,
          unrevealed:         record.unrevealed?,
          bookmarkable_type:  'Work',
          bookmarkable_join:  { name: "bookmarkable" }
        )
      end
    end
  end
end
