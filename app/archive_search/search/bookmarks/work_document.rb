# frozen_string_literal: true

module Search
  module Bookmarks
    class WorkDocument < Search::Base::Document
      include Search::Shared::CreatableDocument
      include Search::Shared::TaggableDocument

      WHITELISTED_ATTRIBUTES = %w(
        complete created_at hidden_by_admin posted
        restricted revised_at summary title word_count
      ).freeze

      def as_json(options = {})
        record.as_json(
          only: WHITELISTED_ATTRIBUTES
        ).merge(
          language_id:        record.language_short,
          anonymous:          record.anonymous?,
          unrevealed:         record.unrevealed?,
          bookmarkable_type:  'Work',
          bookmarkable_join:  { name: "bookmarkable" }
        ).merge(
          creator_data,
          tag_data
        ).merge(options)
      end
    end
  end
end
