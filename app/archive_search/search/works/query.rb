# frozen_string_literal: true

module Search
  module Works
    class Query < Search::Base::Query
      include Search::Shared::TaggableQuery

      def klass
        'Work'
      end

      def indexer
        Search::Works::Indexer.new
      end

      ####################
      # FILTERS
      ####################

      def add_filters
        add_term_filters
        add_terms_filters
        add_tag_names
        exclude_tag_ids
        exclude_tag_names
        add_misc_filters
      end

      def add_queries
      end

      def add_term_filters
        query.add_term_filter(:posted, true)
        query.add_term_filter(:hidden_by_admin, false)
        query.add_term_filter(:restricted, false) unless include_restricted?
        query.add_term_filter(:in_unrevealed_collection, false) unless include_unrevealed?
        query.add_term_filter(:in_anon_collection, false) unless include_anon?
        query.add_term_filter(:chapter_count, 1) if options[:single_chapter].present?

        %i(complete language crossover).each do |field|
          query.add_term_filter(field, options[field])
        end

        filter_ids.map do |filter_id|
          query.add_term_filter(:filter_ids, filter_id)
        end
      end

      def add_terms_filters
        %i(work_types).each do |field|
          query.add_terms_filter(field, options[field])
        end
        query.add_terms_filter("creators.user_id", user_ids) if user_ids.present?
        query.add_terms_filter("creators.id", pseud_ids) if pseud_ids.present?
        query.add_terms_filter("collections.id", options[:collection_ids]) if options[:collection_ids].present?
      end

      def add_tag_names
        return if included_tag_names.blank?
        query.add_match_filter(:tag, included_tag_names.join(" "))
      end

      def exclude_tag_ids
        exclusion_ids.map do |exclusion_id|
          query.exclude_term(:filter_ids, exclusion_id)
        end
      end

      def exclude_tag_names
        excluded_tag_names.map do |tag_name|
          query.add_must_not(
            multi_match: {
              query: tag_name,
              fields: tag_name_fields
            }
          )
        end
      end

      # The various index fields where tag names abide
      def tag_name_fields
        Tag::TAGGABLE_TYPES.map do |tag_type|
          "#{tag_type.humanize.pluralize}.name"
        end + ["tags.name", "meta_tags.name"]
      end

      def add_misc_filters
        query.add_filter(date_range_filter)
        query.add_filter(word_count_filter)
        range_filters.each { |filter| query.add_filter(filter) }
      end

      def range_filters
        ranges = []
        [:word_count, :hit_count, :kudos_count, :comments_count, :bookmarks_count, :revised_at].each do |countable|
          if options[countable].present?
            ranges << { range: { countable => SearchRange.parsed(options[countable]) } }
          end
        end
        ranges += [date_range_filter, word_count_filter].compact
        ranges
      end

      def date_range_filter
        return unless options[:date_from].present? || options[:date_to].present?
        begin
          range = {}
          range[:gte] = clamp_search_date(options[:date_from].to_date) if options[:date_from].present?
          range[:lte] = clamp_search_date(options[:date_to].to_date) if options[:date_to].present?
          { range: { revised_at: range } }
        rescue ArgumentError
          nil
        end
      end

      def word_count_filter
        return unless options[:words_from].present? || options[:words_to].present?
        {
          range: {
            word_count: {
              gte: numberize(options[:words_from]),
              lte: numberize(options[:words_to])
            }
          }
        }
      end

      def numberize(str)
        return if str.blank?
        str.delete(",._").to_i
      end

      ####################
      # QUERIES
      ####################

      # Search for a tag by name
      # Note that fields don't need to be explicitly included in the
      # field list to be searchable directly (ie, "complete:true" will still work)
      def general_query
        input = (options[:q] || options[:query] || "").dup
        query = generate_search_text(input)
        return if query.blank?
        {
          query_string: {
            query: query,
            fields: ["creators^5", "title^7", "endnotes", "notes", "summary", "tag", "series.title"],
            default_operator: "AND"
          }
        }
      end

      def generate_search_text(query = '')
        [
          query,
          title_query_text,
          creators_query_text,
          series_query_text,
          collected_query_text
        ].compact.join(" ")
      end

      def title_query_text
        return if options[:title].blank?
        split_query_text_words(:title, options[:title])
      end

      def creators_query_text
        return if options[:creators].blank?
        split_query_text_words(:creators, options[:creators])
      end

      def series_query_text
        return if options[:series].blank?
        split_query_text_words("series.title", options[:series])
      end

      # Get all works that have collections
      def collected_query_text
        if options[:collection_ids].blank? && collected?
          "collections.id:*"
        end
      end

      def sort
        column = options[:sort_column].present? ? options[:sort_column] : default_sort
        direction = options[:sort_direction].present? ? options[:sort_direction] : 'desc'
        sort_hash = { column => { order: direction } }

        if column == 'revised_at'
          sort_hash[column][:unmapped_type] = 'date'
        end

        sort_hash
      end

      # When searching outside of filters, use relevance instead of date
      def default_sort
        facet_tags? || collected? ? 'revised_at' : '_score'
      end

      def aggregations
        aggs = {}
        if collected?
          aggs[:collections] = { terms: { field: 'collection_ids' } }
        end

        if facet_tags?
          %w(rating archive_warning category fandom character relationship freeform).each do |facet_type|
            aggs[facet_type] = { terms: { field: "#{facet_type}_ids" } }
          end
        end

        { aggs: aggs }
      end

      ####################
      # HELPERS
      ####################

      def facet_tags?
        options[:faceted]
      end

      def collected?
        options[:collected]
      end

      def include_restricted?
        User.current_user.present? || options[:show_restricted]
      end

      # Include unrevealed works only if we're on a collection page
      # OR the collected works page of a user
      def include_unrevealed?
        options[:collection_ids].present? || collected?
      end

      # Include anonymous works if we're not on a user/pseud page
      # OR if the user is viewing their own collected works
      def include_anon?
        (user_ids.blank? && pseud_ids.blank?) ||
          (collected? && options[:works_parent].present? && options[:works_parent] == User.current_user)
      end

      def user_ids
        options[:user_ids]
      end

      def pseud_ids
        options[:pseud_ids]
      end

      # By default, ES6 expects yyyy-MM-dd and can't parse years with 4+ digits.
      def clamp_search_date(date)
        return date.change(year: 0) if date.year.negative?
        return date.change(year: 9999) if date.year > 9999
        date
      end
    end
  end
end
