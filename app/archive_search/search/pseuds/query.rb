# frozen_string_literal: true

module Search
  module Pseuds
    # Query builder for pseud searches
    class Query < Search::Base::Query
      def indexer_class
        Indexer
      end

      def result_class
        Result
      end

      # Filters that the results must match, generally number fields
      def filters
        @filters = tag_id_filters
      end

      # Text queries that the results must match
      def musts
        @musts = [
          general_query,
          name_query
        ].compact
      end

      # Returns an array of term filters for general or public tag ids
      def tag_id_filters
        return [] if options[:tag_ids].blank?
        field = logged_in? ? "tags.id" : "public_tags.id"
        options[:tag_ids].map { |id| term_filter(field, id) }
      end

      # General text search that runs against multiple fields
      def general_query
        query_string = options[:q]
        return if query_string.blank?
        fields = ["byline^5", "name^4", "user_login^2", "description"]
        simple_query_string_query(fields, query_string)
      end

      # Name search
      def name_query
        return if options[:name].blank?
        match_query(:byline, options[:name])
      end

      # Determines what the current user has access to
      def logged_in?
        options[:current_user].is_a?(User)
      end
    end
  end
end
