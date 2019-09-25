# frozen_string_literal: true

module Search
  module Base
    class Query
      attr_reader :options, :client, :query

      # Options: page, per_page
      def initialize(options = {})
        @options = HashWithIndifferentAccess.new(options)
        @query = Search::Builder.new
        @client = Search::Client.new_client
      end

      def indexer
        Indexer.new
      end

      def index_name
        indexer.index_name
      end

      def document_type
        indexer.document_type
      end

      # Add the appropriate options to the query
      # and then return them as a hash
      def search_body
        construct_query
        query.body
      end

      # Execute an Elasticsearch search with our query data
      def search
        client.search(
          index: index_name,
          type: document_type,
          body: search_body
        )
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest
        { error: "Your search failed because of a syntax error. Please try again." }
      end

      # Run a search and return the results in an appropriate format
      def search_results
        Result.new(search)
      end

      # Perform a count query based on the given options
      def count
        client.count(
          index: index_name,
          body: { query: search_body[:query] }
        )['count']
      end

      ### QUERY CONSTRUCTION ###

      def construct_query
        set_sorting
        set_pagination
        add_filters
        add_queries
      end

      # Sort by relevance by default
      def set_sorting
        query.set_sorting("_score", "desc")
      end

      def set_pagination
        query.set_pagination(page: options[:page])
      end

      def add_filters
      end

      def add_queries
      end
    end
  end
end
