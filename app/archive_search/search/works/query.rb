# frozen_string_literal: true

module Search
  module Works
    # Query builder for work searches
    class Query
      include Search::Shared::TaggableQuery

      attr_reader :options, :body

      def initialize(options)
        @options = options.with_indifferent_access
        @body = Search::Body.new
      end

      def to_hash
        build_body
        body.to_hash
      end

      def build_body
        add_filters
        add_queries
        add_exclusions
        add_aggregations
        set_sorting
        set_pagination
      end

      # Boolean, id, number, and date filters
      def add_filters
        add_term_filters
        add_terms_filters
        add_range_filters
      end

      # The text-based options the results must match
      def add_queries
        add_general_query
        add_title_query
        add_creators_query
        add_series_query
        add_collected_query
        add_tag_name_query
      end

      # Results to exclude
      def add_exclusions
        add_tag_exclusions
        add_tag_name_exclusion_queries
      end

      # Facets for filterable pages
      def add_aggregations
        add_collection_aggregation
        add_tag_aggregations
      end

      def set_sorting
        body.sort(
          options[:sort_column] || '_score',
          options[:sort_direction] || 'desc'
        )
      end

      def set_pagination
        body.page(options[:page] || 1).per_page(ArchiveConfig.items_per_page)
      end

      # Combine all our term filters
      def add_term_filters
        body.filter(:term, posted: true)
        body.filter(:term, hidden_by_admin: false)
        body.filter(:term, restricted: false) unless include_restricted?
        body.filter(:term, unrevealed: false) unless include_unrevealed?
        body.filter(:term, anonymous: false)  unless include_anon?
        body.filter(:term, chapter_count: 1)  if options[:single_chapter]

        %i(complete language crossover).map do |field|
          value = options[field]
          body.filter(:term, field => value) unless value.nil?
        end
        add_tag_filters
      end

      # Terms filters that match arrays of values
      def add_terms_filters
        add_work_type_filter
        add_user_filter
        add_pseud_filter
        add_collection_filter
      end

      # Work types are keywords here so they can be filtered on
      def add_work_type_filter
        return if options[:work_types].blank?
        body.filter(:terms, work_types: options[:work_types])
      end

      def add_user_filter
        return if options[:user_ids].blank?
        body.filter(:terms, "creators.user_id" => options[:user_ids])
      end

      def add_pseud_filter
        return if options[:pseud_ids].blank?
        body.filter(:terms, "creators.id" => options[:pseud_ids])
      end

      def add_collection_filter
        return if options[:collection_ids].blank?
        body.filter(:terms, "collections.id" => options[:collection_ids])
      end

      # Takes user input for number and date fields
      # and turns it into range filters
      def add_range_filters
        %i(word_count hit_count kudos_count comments_count bookmarks_count revised_at).each do |countable|
          next unless options[countable]
          range = Search::RangeParser.string_to_range(options[countable])
          body.filter(:range, countable => range) unless range.blank?
        end
        add_date_range_filter
        add_word_count_filter
      end

      def add_date_range_filter
        return unless options[:date_from] || options[:date_to]
        range = {}
        range[:gte] = options[:date_from] if options[:date_from]
        range[:lte] = options[:date_to] if options[:date_to]
        body.filter(:range, revised_at: range)
      end

      def add_word_count_filter
        return unless options[:words_from] || options[:words_to]
        range = {}
        range[:gte] = options[:words_from] if options[:words_from]
        range[:lte] = options[:words_to] if options[:words_to]
        body.filter(:range, word_count: range)
      end

      ####################
      # QUERIES
      ####################

      # Search for a tag by name
      # Note that fields don't need to be explicitly included in the
      # field list to be searchable directly (ie, "complete:true" will still work)
      def add_general_query
        fields = [
          "creators.name^5",
          "title^7",
          "endnotes",
          "notes",
          "summary",
          "tags.name",
          "series.title"
        ]
        query_string = options[:q]
        return if query_string.blank?
        body.must(
          :query_string,
          fields: fields,
          query: query_string
        )
      end

      def add_title_query
        return if options[:title].blank?
        body.must(:match, title: options[:title])
      end

      def add_creators_query
        return if options[:creators].blank?
        body.must(:match, "creators.name" => options[:creators])
      end

      def add_series_query
        return if options[:series].blank?
        body.must(:match, "series.title", options[:series])
      end

      # Get all works that have collections
      def add_collected_query
        return if options[:collection_ids].present? || !collected?
        body.must(:query_string, "collections.id" => "*")
      end

      def add_collection_aggregation
        body.aggregate(:collections, :collection_ids) if collected?
      end

      ####################
      # HELPERS
      ####################

      def filtered?
        options[:filtered]
      end

      def collected?
        options[:collected]
      end

      def include_restricted?
        options[:current_user].present? || options[:show_restricted]
      end

      # Include unrevealed works only if we're on a collection page
      # OR the collected works page of a user
      def include_unrevealed?
        options[:collection_ids].present? || collected?
      end

      def include_anon?
        false
      end
    end
  end
end
