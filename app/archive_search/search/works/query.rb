# frozen_string_literal: true

module Search
  module Works
    # Query builder for work searches
    class Query < Search::Base::Query
      def klass
        'Work'
      end

      def indexer_class
        Indexer
      end

      ####################
      # FILTERS
      ####################

      # Boolean, id, number, and date filters
      def filters
        [
          term_filters,
          terms_filters,
          range_filters
        ].flatten.compact
      end

      # The text-based options the results must match
      def musts
        [
          general_query,
          title_query,
          creators_query,
          series_query,
          collected_query,
          tag_name_query
        ].flatten.compact
      end

      # Results to exclude
      def must_nots
        [
          tag_exclusions,
          tag_name_exclusion_queries
        ].flatten.compact
      end

      # Facets for filterable pages
      def aggregations
        (collection_aggregation || {}).
          merge(tag_aggregations || {})
      end

      # Combine all our term filters
      def term_filters
        [
          term_filter(:posted, true),
          term_filter(:hidden_by_admin, false)
        ] + conditional_filters + boolean_filters + tag_filters
      end

      # Simple filters based on boolean values
      def conditional_filters
        conditionals = []
        unless include_restricted?
          conditionals << term_filter(:restricted, false)
        end
        unless include_unrevealed?
          conditionals << term_filter(:unrevealed, false)
        end
        unless include_anon?
          conditionals << term_filter(:anonymous, false)
        end
        if options[:single_chapter].present?
          conditionals << term_filter(:chapter_count, 1)
        end
        conditionals
      end

      # More boolean filters based on user input
      def boolean_filters
        %i(complete language crossover).map do |field|
          value = options[field]
          term_filter(field, value) unless value.nil?
        end
      end

      # Returns an array of term filters for tag ids
      def tag_filters
        return [] if options[:filter_ids].blank?
        options[:filter_ids].map do |filter_id|
          term_filter(:filter_ids, filter_id)
        end
      end

      # Terms filters that match arrays of values
      def terms_filters
        [
          work_type_filter, user_filter, pseud_filter, collection_filter
        ].compact
      end

      # Work types are keywords here so they can be filtered on
      def work_type_filter
        return if options[:work_types].blank?
        terms_filter(:work_types, options[:work_types])
      end

      def user_filter
        return if options[:user_ids].blank?
        terms_filter("creators.user_id", options[:user_ids])
      end

      def pseud_filter
        return if options[:pseud_ids].blank?
        terms_filter("creators.id", options[:pseud_ids])
      end

      def collection_filter
        return if options[:collection_ids].blank?
        terms_filter("collections.id", options[:collection_ids])
      end

      # Combine remaining tag names and add a query for them
      def tag_name_query
        return if options[:tag_names].blank?
        multi_match_query(
          tag_name_fields,
          options[:tag_names].join(" ")
        )
      end

      # Returns an array of tag term filters to exclude
      def tag_exclusions
        return [] if options[:excluded_tag_ids].blank?
        options[:excluded_tag_ids].map do |exclusion_id|
          term_filter(:filter_ids, exclusion_id)
        end
      end

      # Returns an array of match filters for excluded tag names
      def tag_name_exclusion_queries
        return [] if options[:excluded_tag_names].blank?
        options[:excluded_tag_names].map do |tag_name|
          multi_match_query(tag_name_fields, tag_name)
        end
      end

      # The various index fields where tag names abide
      def tag_name_fields
        Tag::TAGGABLE_TYPES.map do |tag_type|
          "#{tag_type.humanize.pluralize}.name"
        end + ["tags.name", "meta_tags.name"]
      end

      # Takes user input for number and date fields
      # and turns it into range filters
      def range_filters
        ranges = %i(word_count hit_count kudos_count comments_count bookmarks_count revised_at).map do |countable|
          next unless options[countable]
          range = Search::RangeParser.string_to_range(options[countable])
          next if range.blank?
          range_filter(
            countable,
            min: range[:min],
            max: range[:max]
          )
        end
        ranges + [date_range_filter, word_count_filter]
      end

      def date_range_filter
        return unless options[:date_from] || options[:date_to]
        range_filter(
          :revised_at,
          min: options[:date_from],
          max: options[:date_to]
        )
      end

      def word_count_filter
        return unless options[:words_from] || options[:words_to]
        range_filter(
          :word_count,
          min: options[:words_from],
          max: options[:words_to]
        )
      end

      ####################
      # QUERIES
      ####################

      # Search for a tag by name
      # Note that fields don't need to be explicitly included in the
      # field list to be searchable directly (ie, "complete:true" will still work)
      def general_query
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
        query_string_query(fields, query_string) if query_string.present?
      end

      def title_query
        return if options[:title].blank?
        match_query(:title, options[:title])
      end

      def creators_query
        return if options[:creators].blank?
        match_query("creators.name", options[:creators])
      end

      def series_query
        return if options[:series].blank?
        match_query("series.title", options[:series])
      end

      # Get all works that have collections
      def collected_query
        return if options[:collection_ids].present? || !collected?
        query_string_query("collections.id", "*")
      end

      def collection_aggregation
        terms_aggregation(:collections, :collection_ids) if collected?
      end

      def tag_aggregations
        return unless filtered?
        Tag::TAGGABLE_TYPES.inject({}) do |aggs, tag_type|
          label = tag_type.underscore
          aggs.merge!(
            terms_aggregation(label, "#{label}_ids")
          )
        end
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
