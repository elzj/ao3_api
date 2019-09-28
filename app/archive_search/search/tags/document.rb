# frozen_string_literal: true

module Search
  module Tags
    # Creates an indexable hash of tag data
    class Document
      WHITELISTED_ATTRIBUTES = %w(
        id canonical created_at merger_id name sortable_name unwrangleable
      ).freeze

      attr_reader :record

      def initialize(record)
        @record = record
      end

      def as_json(options = {})
        record.as_json(
          root: false,
          only: WHITELISTED_ATTRIBUTES,
        ).merge(
          has_posted_works: record.has_posted_works?,
          tag_type:         record.type,
          uses:             record.taggings_count_cache
        ).merge(parent_data)
      end

      # Index parent data for tag wrangling searches
      def parent_data
        data = {}
        %w(Media Fandom Character).each do |parent_type|
          if record.parent_types.include?(parent_type)
            key = "#{parent_type.downcase}_ids"
            data[key] = record.parents.by_type(parent_type).pluck(:id)
            next if parent_type == "Media"
            data["pre_#{key}"] = record.suggested_parent_ids(parent_type)
          end
        end
        data
      end
    end
  end
end
