# frozen_string_literal: true

module Search
  module Tags
    # Query builder for tag searches
    class Query < Search::Base::Query
      def klass
        'Tag'
      end

      def indexer_class
        Indexer
      end

      # Filters that the results must match, generally number fields
      def filters
        @filters = (
          term_filters + terms_filters + [wrangled_filter]
        ).compact
      end

      # Text queries that the results must match
      def musts
        @musts = [name_query].compact
      end

      # Return an array of term filters for each of our
      # keyword and boolean options
      def term_filters
        %i(tag_type canonical unwrangleable has_posted_works).map do |field|
          value = options[field]
          term_filter(field, value) unless value.nil?
        end
      end

      # Return an array of terms filters for each of our id options
      def terms_filters
        %i(media_ids fandom_ids character_ids pre_fandom_ids pre_character_ids).map do |field|
          value = options[field]
          terms_filter(field, value) unless value.nil?
        end
      end

      # Say a tag is wrangled if it has fandoms
      def wrangled_filter
        exists_filter(:fandom_ids) if options[:wrangled]
      end

      # Search by tag name, weighting exact matches higher
      def name_query
        fields = ["name.exact^2", "name"]
        query_string_query(fields, options[:name]) if options[:name].present?
      end
    end
  end
end
