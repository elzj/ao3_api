# frozen_string_literal: true

module Search
  # The main interface between the model and the custom search code
  class TagSearch
    include ActiveModel::Model
    include Search::Tags::Settings
    include Search::Shared::SearchMethods

    ATTRIBUTES = %w(
      q name tag_type canonical
      current_user sort_column sort_direction
    ).freeze

    attr_accessor(*ATTRIBUTES)

    # The JSON document to be indexed
    def self.document(tag)
      Search::Tags::Document.new(tag).as_json
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
      Search::Tags::Query.new(attributes).to_hash
    end

    # Pass our query to the searchkick search method
    def search_results(load: true)
      Tag.search(body: search_body, load: load)
    end

    def process_input
      @processed = true
    end
  end
end
