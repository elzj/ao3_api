# frozen_string_literal: true

module Search
  module Shared
    # Shares code among query classes for models with tags
    module TaggableQuery
      def filter_ids
        options[:filter_ids]
      end

      def included_tag_names
        options[:tag_names]
      end

      # Returns an array of term filters for tag ids
      def tag_filters
        return [] if options[:filter_ids].blank?
        options[:filter_ids].map do |filter_id|
          term_filter(:filter_ids, filter_id)
        end
      end

      # Combine remaining tag names and add a query for them
      def tag_name_query
        return if options[:tag_names].blank?
        multi_match_query(
          tag_name_fields,
          options[:tag_names].join(" ")
        )
      end

      # Returns an array of tag term filters to exclude
      def tag_exclusions
        return [] if options[:excluded_tag_ids].blank?
        options[:excluded_tag_ids].map do |exclusion_id|
          term_filter(:filter_ids, exclusion_id)
        end
      end

      # Returns an array of match filters for excluded tag names
      def tag_name_exclusion_queries
        return [] if options[:excluded_tag_names].blank?
        options[:excluded_tag_names].map do |tag_name|
          multi_match_query(tag_name_fields, tag_name)
        end
      end

      # The various index fields where tag names abide
      def tag_name_fields
        Tag::TAGGABLE_TYPES.map do |tag_type|
          "#{tag_type.humanize.pluralize}.name"
        end + ["tags.name", "meta_tags.name"]
      end

      def tag_aggregations
        return unless filtered?
        Tag::TAGGABLE_TYPES.inject({}) do |aggs, tag_type|
          label = tag_type.underscore
          aggs.merge!(
            terms_aggregation(label, "#{label}_ids")
          )
        end
      end
    end
  end
end
