# frozen_string_literal: true

module Search
  module Pseuds
    class Query < Search::Base::Query
      def klass
        'Pseud'
      end

      def indexer
        Search::Pseuds::Indexer.new
      end

      def filters
        [collection_filter, fandom_filter].compact
      end

      def queries
        [general_query, name_query].compact
      end

      ###########
      # FILTERS
      ###########

      def collection_filter
        { term: { collection_ids: options[:collection_id] } } if options[:collection_id]
      end

      def fandom_filter
        key = User.current_user.present? ? "fandoms.id" : "fandoms.id_for_public"
        if options[:fandom_ids]
          options[:fandom_ids].map do |fandom_id|
            { term: { key => fandom_id } }
          end
        end
      end

      ###########
      # QUERIES
      ###########

      def general_query
        {
          simple_query_string:{
            query: escape_reserved_characters(options[:query]),
            fields: ["byline^5", "name^4", "user_login^2", "description"],
            default_operator: "AND"
          }
        } if options[:query]
      end

      def name_query
        { match: { byline: escape_reserved_characters(options[:name]) } } if options[:name]
      end
    end
  end
end
