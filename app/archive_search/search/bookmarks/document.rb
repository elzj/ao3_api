# frozen_string_literal: true

module Search
  module Bookmarks
    # Creates an indexable hash of bookmark data
    class Document
      include Search::Shared::CollectibleDocument
      include Search::Shared::TaggableDocument

      WHITELISTED_ATTRIBUTES = %i(
        id bookmarkable_type bookmarkable_id
        hidden_by_admin private rec
        created_at updated_at
      ).freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def as_json(options = {})
        record.as_json(
          only: WHITELISTED_ATTRIBUTES,
          methods: [:bookmarkable_date]
        ).merge(
          notes: record.bookmarker_notes,
          with_notes: record.bookmarker_notes.present?
        ).merge(
          bookmarker_data,
          collection_data,
          tag_data,
          bookmarkable_join
        ).merge(options).with_indifferent_access
      end

      def bookmarker_data
        pseud = record.pseud
        {
          bookmarker: {
            id: pseud.id,
            name: pseud.name,
            user_id: pseud.user_id,
            user_login: pseud.user_login
          }
        }
      end

      def bookmarkable_join
        return {} if parent_deleted?
        {
          bookmarkable_join: {
            name: "bookmark",
            parent: parent_id
          }
        }
      end

      def parent_deleted?
        record.bookmarkable.nil?
      end

      # We store bookmarks and bookmarkables in the same index
      # so we need to avoid id collision by disambiguating
      # Example: '5-work', '33-external_work'
      def parent_id
        [
          record.bookmarkable_id,
          record.bookmarkable_type.underscore
        ].join("-")
      end
    end
  end
end
