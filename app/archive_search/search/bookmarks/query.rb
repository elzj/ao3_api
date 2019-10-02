# frozen_string_literal: true

module Search
  module Bookmarks
    # Query builder for bookmark searches
    class Query
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
      end

      def add_filters
        add_bookmark_filters
        add_type_filter
        add_date_filter
        add_association_filters
        add_parent_filters
      end

      def add_queries
        add_general_query
        add_tag_name_query
      end

      def add_exclusions
        add_tag_exclusion_filter
        add_tag_name_exclusion_filter
      end

      def add_general_query
        return if options[:q].blank?
        body.must(
          :query_string,
          query: options[:q],
          default_operator: "AND"
        )
      end

      def add_bookmark_filters
        body.filter(:term, private: false) unless include_private?
        body.filter(:term, hidden_by_admin: false)
        body.filter(:term, rec: true) if options[:rec]
        body.filter(:term, with_notes: true) if options[:with_notes]
        # Only include actual bookmarks
        body.filter(:term, bookmarkable_join: "bookmark")
      end

      def add_type_filter
        type = options[:bookmarkable_type]
        return if type.blank?
        body.filter(:term, bookmarkable_type: type.delete(" "))
      end

      # The date filter on the bookmark (i.e. when the bookmark was created).
      def add_date_filter
        return if options[:date].blank?
        range = Search::RangeParser.string_to_range(options[:date])
        return if range.blank?
        body.filter(:range, created_at: range)
      end

      def add_association_filters
        %i(pseud_ids user_ids collection_ids tag_ids).each do |field|
          next if options[field].blank?
          options[field].each { |id| body.filter(:term, field => id) }
        end
      end

      def add_tag_exclusion_filter
        body.must_not(:terms, tag_ids: excluded_bookmark_tag_ids) if excluded_bookmark_tag_ids.present?
      end

      # This filter is used to restrict our results to only include bookmarks whose
      # "tag" text matches all of the tag names in included_bookmark_tag_names.
      # This is useful when the user enters a non-existent tag, which would be
      # discarded by the included_bookmark_tag_ids function.
      def add_tag_name_query
        return if options[:tag_names].blank?
        body.must(:match, "tags.name" => options[:tag_names].join(" "))
      end

      # This set of filters is used to prevent us from matching any bookmarks
      # whose "tag" text matches one of the passed-in tag names. This is useful
      # when the user enters a non-existent tag, which would be discarded by the
      # excluded_bookmark_tag_ids function.
      #
      # Unlike the inclusion filter, we separate the queries to make sure that with
      # tags "A B" and "C D", we're searching for "not(A and B) and not(C and D)",
      # instead of "not(A and B and C and D)" or "not(A or B or C or D)".
      def add_tag_name_exclusion_filter
        excluded_bookmark_tag_names.each do |tag_name|
          body.must_not(:match, "tags.name" => tag_name)
        end
      end

      def add_parent_filters
        parent_query = Search::Body.new
        parent_query.must_not(:term, posted: false)
        parent_query.must_not(:term, hidden_by_admin: true)
        if options[:filter_ids]
          options[:filter_ids].each do |id|
            parent_query.filter(:term, filter_ids: id)
          end
        end
        body.must(
          :has_parent,
          parent_type: "bookmarkable",
          query: parent_query.to_hash[:query]
        )
      end

      def include_private?
        # Use fetch instead of || here to make sure that we don't accidentally
        # override a deliberate choice not to show private bookmarks.
        options.fetch(
          :show_private,
          logged_in? && user_ids == [options[:current_user].id]
        )
      end

      def excluded_bookmark_tag_ids
        options[:excluded_bookmark_tag_ids] || []
      end

      def excluded_bookmark_tag_names
        options[:excluded_bookmark_tag_names] || []
      end

      def user_ids
        options[:user_ids]
      end

      # Determines what the current user has access to
      def logged_in?
        options[:current_user].is_a?(User)
      end
    end
  end
end
