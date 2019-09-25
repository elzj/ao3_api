# frozen_string_literal: true

module Search
  module Pseuds
    class Document
      WHITELISTED_ATTRIBUTES = %w[
        id name user_id description created_at
      ].freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def to_hash
        record.as_json(
          root: false,
          only: WHITELISTED_ATTRIBUTES,
          methods: [
            :user_login,
            :byline,
            :collection_ids
          ]
        ).merge(
          sortable_name: record.name.downcase,
          fandoms: fandoms,
          general_bookmarks_count: general_bookmarks_count,
          public_bookmarks_count: public_bookmarks_count,
          general_works_count: general_works_count,
          public_works_count: public_works_count
        )
      end

      private

      def general_works_count
        work_counts.values.sum
      end

      def public_works_count
        work_counts[false] || 0
      end

      def fandoms
        tag_info("Fandom")
      end

      # Produces an array of hashes with the format
      # [{id: 1, name: "Star Trek", count: 5}]
      def tag_info(tag_type)
        all_uses = record.direct_filters
          .where(works: countable_works_conditions)
          .by_type(tag_type)
          .group_by(&:id)
        
        public_uses = record.direct_filters
          .where(works: public_works_conditions)
          .by_type(tag_type)
          .group_by(&:id)

        info = all_uses.map do |id, tags|
          { id: id, name: tags.first.name, count: tags.length }
        end

        info += public_uses.map do |id, tags|
          { id_for_public: id, name: tags.first.name, count: tags.length }
        end

        info
      end

      # The relation containing all bookmarks that should be included in the count
      # for logged-in users (when restricted to a particular pseud).
      def general_bookmarks
        @general_bookmarks ||=
          Bookmark.with_missing_bookmarkable.
          or(Bookmark.with_bookmarkable_visible_to_registered_user).
          is_public
      end

      # The relation containing all bookmarks that should be included in the count
      # for logged-out users (when restricted to a particular pseud).
      def public_bookmarks
        @public_bookmarks ||=
          Bookmark.with_missing_bookmarkable.
          or(Bookmark.with_bookmarkable_visible_to_all).
          is_public
      end

      def general_bookmarks_count
        general_bookmarks.merge(record.bookmarks).count
      end

      def public_bookmarks_count
        public_bookmarks.merge(record.bookmarks).count
      end

      # Creates a hash of the form { true: 5, false: 3 }
      def work_counts
        @work_counts ||= record.works.where(
          countable_works_conditions
        ).group(:restricted).count
      end

      def countable_works_conditions
        {
          posted: true,
          hidden_by_admin: false,
          in_anon_collection: false,
          in_unrevealed_collection: false
        }
      end

      def public_works_conditions
        countable_works_conditions.merge(restricted: false)
      end
    end
  end
end
