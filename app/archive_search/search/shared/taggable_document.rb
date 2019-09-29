# frozen_string_literal: true

module Search
  module Shared
    # Shares code among document classes for models with tags
    module TaggableDocument
      # Returns a hash with an array of this record's tag data
      def tag_data
        direct_filter_data.merge(
          tags: tags,
          meta_tags: tag_list(meta_tags),
          filter_ids: filter_ids
        )
      end

      def tags
        @tags ||= record.tags.pluck_as_hash(:id, :name, :type)
      end

      def filters
        @filters ||= record.filters.
          select(:id, :name, :type).
          select("filter_taggings.inherited AS inherited")
      end

      # Combine all tag ids for ease of querying
      def filter_ids
        (tags.map { |tag| tag[:id] } + filters.map(&:id)).uniq
      end

      def direct_filters
        @direct_filters ||= filters.select { |tag| tag.inherited.zero? }
      end

      def meta_tags
        filters - direct_filters
      end

      def tag_list(tags)
        tags.map { |tag| tag.attributes.slice('id', 'name', 'type') }
      end

      # We need to break these out by type so we can aggregate by them
      def direct_filter_data
        data = {}
        direct_filters.group_by { |tag| tag.type.underscore.pluralize }.
          each_pair { |type, values| data[type] = tag_list(values) }
        data
      end
    end
  end
end
