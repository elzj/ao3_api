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

      # Adds term filters for tag ids
      def add_tag_filters
        return if options[:filter_ids].blank?
        options[:filter_ids].each do |filter_id|
          body.filter(:term, filter_ids: filter_id)
        end
      end

      # Combine remaining tag names and add a query for them
      def add_tag_name_query
        return if options[:tag_names].blank?
        body.must(
          :multi_match,
          field: tag_name_fields,
          query: options[:tag_names].join(" ")
        )
      end

      # Returns an array of tag term filters to exclude
      def add_tag_exclusions
        return if options[:excluded_tag_ids].blank?
        options[:excluded_tag_ids].each do |exclusion_id|
          body.must_not(:term, filter_ids: exclusion_id)
        end
      end

      # Returns an array of match filters for excluded tag names
      def add_tag_name_exclusion_queries
        return if options[:excluded_tag_names].blank?
        options[:excluded_tag_names].each do |tag_name|
          body.must_not(
            :multi_match,
            field: tag_name_fields,
            query: tag_name
          )
        end
      end

      # The various index fields where tag names abide
      def tag_name_fields
        Tag::TAGGABLE_TYPES.map do |tag_type|
          "#{tag_type.humanize.pluralize}.name"
        end + ["tags.name", "meta_tags.name"]
      end

      def add_tag_aggregations
        return unless filtered?
        Tag::TAGGABLE_TYPES.inject({}) do |aggs, tag_type|
          label = tag_type.underscore.pluralize
          body.aggregate(label, "#{label}.id")
        end
      end
    end
  end
end
