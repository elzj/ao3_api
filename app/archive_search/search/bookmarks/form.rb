# frozen_string_literal: true

module Search
  module Bookmarks
    class Form < Search::Base::Form
      include Search::Shared::TaggableForm

      TAG_FIELDS = %i(
        archive_warning_ids category_ids rating_ids
        character_names character_ids
        fandom_names fandom_ids
        freeform_names freeform_ids
        relationship_names relationship_ids
        excluded_tag_names excluded_tag_ids
        tag_names filter_ids
      ).freeze

      NUMBER_AND_DATE_FIELDS = %i(
      ).freeze

      ASSOCIATION_FIELDS = %i(
        collection_ids language_id pseud_ids user_ids
      ).freeze

      GENERAL_FIELDS = %i(
        page q rec with_notes
        sort_column sort_direction
        filtered current_user parent
      ).freeze

      ATTRIBUTES = (
        TAG_FIELDS +
        NUMBER_AND_DATE_FIELDS +
        ASSOCIATION_FIELDS +
        GENERAL_FIELDS
      ).freeze

      attr_accessor(*ATTRIBUTES)

      def self.permitted_params
        ATTRIBUTES
      end

      def query_class
        Query
      end

      def process_data
        super

        # clean_up_angle_brackets
        add_owner
        load_tags
      end

      def add_owner
        field = case parent
                when Tag
                  :filter_ids
                when Pseud
                  :pseud_ids
                when User
                  :user_ids
                when Collection
                  :collection_ids
                end
        return unless field.present?
        value = send(field) || []
        send("#{field}=", value + [owner.id])
      end

      def legal_sort_values
        %w(_score created_at)
      end
    end
  end
end
