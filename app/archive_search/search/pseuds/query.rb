# frozen_string_literal: true

module Search
  module Pseuds
    class Query < Search::Base::Query
      def indexer_class
        Indexer
      end

      def result_class
        Result
      end

      # Add the collection and fandom filters
      def add_filters
        return if options[:fandom_ids].blank?
        key = logged_in? ? "fandoms.id" : "fandoms.id_for_public"
        options[:fandom_ids].map do |fandom_id|
          query.add_term_filter(key, fandom_id)
        end
      end

      def add_queries
        query.add_must(general_query) if options[:query]
        query.add_match(:byline, options[:name]) if options[:name]
      end

      def general_query
        {
          simple_query_string: {
            query: options[:query],
            fields: ["byline^5", "name^4", "user_login^2", "description"],
            default_operator: "AND"
          }
        }
      end

      def logged_in?
        options[:current_user].is_a?(User)
      end
    end
  end
end
