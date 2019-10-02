# frozen_string_literal: true

module Search
  module Pseuds
    # Query builder for pseud searches
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
        add_general_query
        add_name_query
        add_tag_name_query
        add_tag_filters
        add_collection_filters
      end

      def add_general_query
        return if options[:q].blank?
        fields = ["byline^5", "name^4", "user_login^2", "description"]
        body.must(
          :query_string,
          query: options[:q],
          fields: fields
        )
      end

      def add_name_query
        return if options[:name].blank?
        body.must(:match, byline: options[:name])
      end

      def add_tag_name_query
        return if options[:fandom].blank?
        options[:fandom].split(",").map(&:strip).each do |name|
          body.should(:match, tag_name_field => name)
        end
      end

      # Returns an array of term filters for general or public tag ids
      def add_tag_filters
        return if options[:tag_ids].blank?
        field = logged_in? ? "tags.id" : "public_tags.id"
        options[:tag_ids].map do |id|
          body.filter(:term, field => id)
        end
      end

      def add_collection_filters
        return if options[:collection_ids].blank?
        options[:collection_ids].map do |id|
          body.filter(:term, "collections.id" => id)
        end
      end

      def tag_id_field
        logged_in? ? "tags.id" : "public_tags.id"
      end

      def tag_name_field
        logged_in? ? "tags.name" : "public_tags.name"
      end

      # Determines what the current user has access to
      def logged_in?
        options[:current_user].is_a?(User)
      end
    end
  end
end
