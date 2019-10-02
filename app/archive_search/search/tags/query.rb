# frozen_string_literal: true

module Search
  module Tags
    # Query builder for tag searches
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
        add_term_filters
        add_terms_filters
        add_wrangled_filter
        add_name_query
      end

      # Add term filters for each of our keyword and boolean options
      def add_term_filters
        %i(tag_type canonical unwrangleable has_posted_works).map do |field|
          value = options[field]
          body.filter(:term, field => value) unless value.nil?
        end
      end

      # Add terms filters for each of our id options
      def add_terms_filters
        %i(media_ids fandom_ids character_ids pre_fandom_ids pre_character_ids).map do |field|
          value = options[field]
          body.filter(:terms, field => value) unless value.nil?
        end
      end

      # Say a tag is wrangled if it has fandoms
      def add_wrangled_filter
        body.filter(:exists, field: :fandom_ids) if options[:wrangled]
      end

      # Search by tag name, weighting exact matches higher
      def add_name_query
        return if options[:name].blank?
        body.must(
          :query_string,
          query: options[:name],
          fields: ["name.exact^2", "name"]
        )
      end
    end
  end
end
