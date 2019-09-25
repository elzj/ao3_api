# frozen_string_literal: true

module Search
  module Tags
    class Query < Search::Base::Query
      def klass
        'Tag'
      end

      def indexer
        Search::Tags::Indexer.new
      end

      def add_filters
        add_term_filters
        add_terms_filters
        add_wrangled_filter
      end

      def add_queries
        add_name_query
      end

      def add_term_filters
        %i[tag_type canonical unwrangleable has_posted_works].each do |term|
          query.add_term_filter(term, options[term])
        end
      end

      def add_terms_filters
        %i[media_ids fandom_ids character_ids pre_fandom_ids pre_character_ids].each do |term|
          query.add_terms_filter(term, options[term])
        end
      end

      def add_wrangled_filter
        return if options[:wrangled].nil?
        query.add_filter({ exists: { field: "fandom_ids" } })
      end

      def add_name_query
        return if options[:name].blank?
        query.add_must({
          query_string: {
            query: options[:name],
            fields: ["name.exact^2", "name"],
            default_operator: "and"
          }
        })
      end
    end
  end
end
