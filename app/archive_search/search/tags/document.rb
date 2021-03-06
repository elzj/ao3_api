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
          only: WHITELISTED_ATTRIBUTES
        ).merge(
          has_posted_works: record.has_posted_works?,
          tag_type:         record.type,
          uses:             record.uses,
          suggest:          suggester_data
        ).merge(parent_data).merge(options)
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

      def suggester_data
        {
          input: suggester_tokens,
          weight: suggester_weight,
          contexts: {
            typeContext: [
              record.type,
              record.canonical? ? "Canonical#{record.type}" : nil
            ].compact
          }
        }
      end

      # Gives the sugggester an array of strings broken up by words
      # For "The Neverending Story", for example, you'd get:
      # ["The Neverending Story", "Neverending Story", "Story"]
      def suggester_tokens
        tokens = [record.name]
        # return tokens if !canonical?
        words = record.name.split(/[^\da-zA-Z]/)
        while words.length > 0
          words.shift
          next if words.first.nil? || words.first.length < 3
          tokens << words.join(" ").squish
        end
        tokens.uniq[0..19]
      end

      def suggester_weight
        record.uses
      end
    end
  end
end
