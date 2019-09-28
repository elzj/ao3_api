# frozen_string_literal: true

module Search
  module Works
    # Creates an indexable hash of work data
    class Document
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
        ).with_indifferent_access
      end

      def series_data
        { series: record.series.pluck_as_hash(:id, :title, :position) }
      end

      def creator_data
        data = pseuds.map do |pseud|
          {
            id: pseud.id,
            name: pseud.name,
            user_id: pseud.user_id,
            user_login: pseud.user_login
          }
        end
        {
          authors_to_sort_on: sorted_byline,
          creators: data
        }
      end

      def stats_data
        record.stat_counter&.as_json(
          root: false,
          only: %w(bookmarks_count comments_count hit_count kudos_count)
        ) || {}
      end

      def tag_data
        direct_filter_data.merge(
          tags: tags,
          meta_tags: tag_list(meta_tags),
          filter_ids: filter_ids
        )
      end

      def tags
        @tags ||= record.tags.pluck_as_hash(:id, :name, :type)
      end

      def filters
        @filters ||= record.filters.
          select(:id, :name, :type).
          select("filter_taggings.inherited AS inherited")
      end

      # Combine all tag ids for ease of querying
      def filter_ids
        (tags.map { |tag| tag[:id] } + filters.map(&:id)).uniq
      end

      def direct_filters
        @direct_filters ||= filters.select { |tag| tag.inherited.zero? }
      end

      def meta_tags
        filters - direct_filters
      end

      def tag_list(tags)
        tags.map { |tag| tag.attributes.slice('id', 'name', 'type') }
      end

      # We need to break these out by type so we can aggregate by them
      def direct_filter_data
        data = {}
        direct_filters.group_by { |tag| tag.type.underscore.pluralize }.
          each_pair { |type, values| data[type] = tag_list(values) }
        data
      end

      def collection_data
        {
          collections: record.approved_collections.pluck_as_hash(:id, :name, :title)
        }
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
      
      def sorted_byline
        scrubber = %r{^[\+\-=_\?!'"\.\/]}
        if record.in_anon_collection?
          "Anonymous"
        else
          pseuds.map { |pseud| pseud.name.downcase }.
            sort.join(", ").downcase.gsub(scrubber, '')
        end
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

      def pseuds
        @pseuds ||= record.pseuds.includes(:user)
      end
    end
  end
end
