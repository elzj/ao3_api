# frozen_string_literal: true

module Search
  module Works
    # Creates an indexable hash of work data
    class Document
      include Search::Shared::CollectibleDocument
      include Search::Shared::CreatableDocument
      include Search::Shared::TaggableDocument

      WHITELISTED_ATTRIBUTES = %w(
        id backdate complete created_at end_notes hidden_by_admin
        imported_from_url major_version minor_version notes
        posted restricted revised_at summary title
        title_to_sort_on updated_at word_count work_skin_id
      ).freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def as_json(options = {})
        record.as_json(
          only: WHITELISTED_ATTRIBUTES
        ).merge(
          collection_data,
          creator_data,
          series_data,
          stats_data,
          tag_data,
          work_data
        ).merge(options).with_indifferent_access
      end

      def series_data
        { series: record.series.pluck_as_hash(:id, :title, :position) }
      end

      def stats_data
        record.stat_counter&.as_json(
          root: false,
          only: %w(bookmarks_count comments_count hit_count kudos_count)
        ) || {}
      end

      def work_data
        {
          anonymous:      record.in_anon_collection?,
          chapter_count:  record.expected_number_of_chapters,
          crossover:      crossover?,
          language:       record.language_short,
          nonfiction:     nonfiction?,
          otp:            otp?,
          unrevealed:     record.in_unrevealed_collection?,
          work_types:     work_types
        }
      end

      def crossover?
        false
      end

      def nonfiction?
        false
      end

      def otp?
        direct_filter_data['relationships'] &&
          direct_filter_data['relationships'].length == 1
      end

      def work_types
        ['Text']
      end
    end
  end
end
