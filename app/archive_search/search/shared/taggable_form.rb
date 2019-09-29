module Search
  module Shared
    module TaggableForm
      def load_tags
        ids = Tag::TAGGABLE_TYPES.flat_map do |tag_type|
          send("#{tag_type.underscore}_ids")
        end
        self.filter_ids = (
          [self.filter_ids] + ids + processed_tag_name_ids
        ).flatten.compact.uniq
        process_exclusions
      end

      def processed_tag_name_ids
        names = parse_tag_names
        tags = Tag.where(name: names).pluck(:id, :name)
        # Use our non-user-facing field to hold the missing
        self.tag_names = names - tags.map(&:last)
        tags.map(&:first)
      end

      def parse_tag_names
        tag_name_fields = %w(
          fandom_names character_names relationship_names
          freeform_names tag_names
        )
        tag_name_fields.flat_map do |field|
          value = send(field)
          next if value.blank?
          value.split(',').map(&:squish).reject(&:blank?)
        end.uniq.compact
      end

      def process_exclusions
        value = self.excluded_tag_names
        return unless value
        names = value.split(',').map(&:squish).reject(&:blank?)
        return if names.blank?
        ids = Tag.where(name: names).pluck(:id)
        self.excluded_tag_ids ||= []
        self.excluded_tag_ids << ids
      end
    end
  end
end
