# frozen_string_literal: true

module Search
  # The main interface between the model and the custom search code
  class BookmarkSearch
    include ActiveModel::Model
    include Search::Bookmarks::Settings
    include Search::Shared::SearchMethods
    include Search::Shared::TaggableSearch

    TAG_FIELDS = %w(
      archive_warning_ids category_ids rating_ids
      character_names character_ids
      fandom_names fandom_ids
      freeform_names freeform_ids
      relationship_names relationship_ids
      excluded_tag_names excluded_tag_ids
      tag_names filter_ids
    ).freeze

    NUMBER_AND_DATE_FIELDS = %w(
    ).freeze

    ASSOCIATION_FIELDS = %w(
      collection_ids language_id pseud_ids user_ids
    ).freeze

    GENERAL_FIELDS = %w(
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

    def attributes
      self.as_json(only: ATTRIBUTES)
    end

    def self.permitted_params
      ATTRIBUTES
    end

    # The JSON document to be indexed
    def self.document(record)
      Search::Bookmarks::Document.new(record).as_json
    end

    def self.mappings
      MAPPINGS
    end

    def self.settings
      SETTINGS
    end

    # Generate an elasticsearch query
    def search_body
      process_input unless processed?
      Search::Bookmarks::Query.new(attributes).to_hash
    end

    # Pass our query to the searchkick search method
    def search_results(load: true)
      Bookmark.search(body: search_body, load: load)
    end

    def process_input
      @processed = true
    end
  end
end
