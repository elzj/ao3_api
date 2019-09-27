# frozen_string_literal: true

module Search
  module Base
    # Builds and executes elasticsearch queries
    class Query
      include Search::Shared::SearchTerms

      attr_reader :client, :options, :filters, :musts, :must_nots, :shoulds, :aggregations

      def initialize(options = {})
        @options = options.with_indifferent_access
        @client = Search::Client.new_client
        @filters = []
        @musts = []
        @must_nots = []
        @shoulds = []
        @aggregations = []
      end

      def indexer_class
        Indexer
      end

      def result_class
        Result
      end

      def index_name
        indexer_class.new.index_name
      end

      # Add the appropriate options to the query
      # and then return them as a hash
      def search_body
        body = Search::Builder.new(
          filter: filters,
          must: musts,
          must_not: must_nots,
          should: shoulds,
          aggregations: aggregations,
          sort_column: sort_column,
          sort_direction: sort_direction,
          page: page,
          per_page: per_page
        ).body
        body
      end

      # Execute an Elasticsearch search with our query data
      def search
        client.search(index: index_name, body: search_body)
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest
        { error: "Your search failed because of a syntax error. Please try again." }
      end

      # Run a search and return the results in an appropriate format
      def search_results
        result_class.new(search)
      end

      # Perform a count query based on the given options
      def count
        client.count(
          index: index_name,
          body: { query: search_body[:query] }
        )['count']
      end

      # Sort by relevance by default
      def sort_column
        options[:sort_column] || "_score"
      end

      def sort_direction
        options[:sort_direction] || "desc"
      end

      def page
        options[:page] || 1
      end

      def per_page
        options[:per_page] || ArchiveConfig.items_per_page
      end
    end
  end
end
